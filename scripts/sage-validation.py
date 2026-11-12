"""Source, Python provenance and test checks for the hosted bottle validation."""

import argparse
import contextlib
import hashlib
import importlib
import importlib.metadata
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import time
import urllib.request
import xml.etree.ElementTree as ET

VERSION = "11.0.beta6"
COMMIT = "0fb03f8fab7ec91f3db5fefbc56f5d758cde072b"
ARCHIVE_SHA256 = "e8bcfaf1d165dac986a38deb695c39d326094d01a05e5dca5e27fcd70a05efc4"
FEATURES = (
    "bliss", "brial", "coxeter3", "eclib", "libbraiding", "libhomfly",
    "mcqd", "meataxe", "rankwidth", "sirocco", "tdlib",
)
# Check distutils before another import can activate setuptools' import hook.
MODULES = (
    "distutils", "Cython", "mesonpy", "mesonbuild.coredata", "memory_allocator", "jinja2", "packaging",
    "cysignals", "cypari2", "gmpy2", "numpy", "scipy", "matplotlib", "PIL",
    "ppl", "cvxopt", "fpylll", "lrcalc", "primecountpy", "sympy",
    "networkx", "IPython", "ipykernel", "ipywidgets",
    "elliptic_curve_databases", "graph_databases", "polytope_databases",
)
TEST_PACKAGES = (
    "pytest==9.1.1", "pytest-xdist==3.8.0", "execnet==2.1.2",
    "iniconfig==2.3.1", "pluggy==1.7.0",
)
DOCTEST_GROUPS = {
    "native": ["src/sage/libs"],
    "linear": ["src/sage/matrix", "src/sage/rings/finite_rings"],
    "graphs": ["src/sage/graphs", "src/sage/databases", "src/sage/features/databases.py"],
    "numeric": ["src/sage/numerical"],
    "interfaces": ["src/sage/interfaces/gap.py", "src/sage/interfaces/maxima.py",
                   "src/sage/interfaces/maxima_lib.py"],
}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def prepare(root, artifacts):
    report = json.loads((artifacts / "bottle-provenance.json").read_text())
    rows = report["formulae"]
    assert report["root_version"].split("_")[0] == VERSION
    assert all(row["receipt"]["poured_from_bottle"] for row in rows)
    by_name = {row["name"]: row for row in rows}
    python_keg = Path(by_name["python@3.14"]["keg"]).resolve(strict=True)
    assert sys.version_info[:2] == (3, 14), sys.version
    assert Path(sys.base_prefix).resolve().is_relative_to(python_keg), sys.base_prefix
    uv = str(Path(by_name["uv"]["keg"]) / "bin/uv")
    venv = root / "venv"
    assert not venv.exists(), "Validation requires a fresh environment"
    subprocess.run([uv, "venv", "--no-project", "--no-config", "--offline",
                    "--python", sys.executable, str(venv)], check=True)
    # Seed pip offline from the bottled Python's bundled wheel. Its check runs
    # inside Python and sees the private sites exposed by executable .pth hooks.
    # uv's static package inventory does not follow those hooks.
    seeded = subprocess.run([str(venv / "bin/python"), "-I", "-B", "-m", "ensurepip", "--default-pip"],
                            check=False, text=True, capture_output=True)
    (artifacts / "ensurepip.log").write_text(seeded.stdout + seeded.stderr)
    seeded.check_returncode()

    sites = []
    relative = Path("lib/python3.14/site-packages")
    deps = by_name["dimpase/tap/sagemath-deps"]
    # Resource versions supplied by sagemath-deps take precedence over helper
    # packages carried privately by another native dependency.
    for row in [deps, *rows]:
        keg = Path(row["keg"]).resolve(strict=True)
        # Homebrew's sitecustomize redirects the interpreter's bundled
        # pip/wheel site to the global site, exposing unrelated installations.
        # uv and the bottled build backend do not need that interpreter site.
        if keg == python_keg or row["name"] == "meson":
            continue
        for path in [keg / "libexec/python3.14" / relative,
                     keg / relative, keg / "libexec" / relative]:
            if not path.is_dir():
                continue
            path = path.resolve()
            assert path.is_relative_to(keg), path
            assert not (path / "sage").exists(), f"Old Sage in {path}"
            if not any(entry["path"] == str(path) for entry in sites):
                sites.append({"path": str(path), "formula": row["name"], "keg": str(keg)})
    # Meson's dedicated pure-Python site can use a different Python minor.
    # Audit only that bottle's site; the sagemath-deps private .pth must expose
    # it itself, without processing any .pth files inside the Meson bottle.
    meson = by_name["meson"]
    meson_keg = Path(meson["keg"]).resolve(strict=True)
    assert meson["receipt"]["source"]["tap"] == "homebrew/core", meson
    meson_sites = list((meson_keg / "lib").glob("python*/site-packages"))
    assert len(meson_sites) == 1, meson_sites
    meson_site = meson_sites[0].resolve(strict=True)
    assert meson_site.is_relative_to(meson_keg)
    metadata_dirs = list(meson_site.glob("meson-*.dist-info"))
    assert len(metadata_dirs) == 1, metadata_dirs
    assert metadata_dirs[0].resolve(strict=True).is_relative_to(meson_keg)
    assert (meson_site / "mesonbuild").resolve(strict=True).is_relative_to(meson_keg)
    assert {p.name for p in meson_site.iterdir()} == {"mesonbuild", metadata_dirs[0].name}
    dist = importlib.metadata.Distribution.at(metadata_dirs[0])
    assert dist.metadata["Name"] == "meson"
    assert "Root-Is-Purelib: true" in dist.read_text("WHEEL")
    assert "Tag: py3-none-any" in dist.read_text("WHEEL")
    sites.append({"path": str(meson_site), "formula": "meson", "keg": str(meson_keg),
                  "append_only": True})
    # Process each private site's .pth files, including setuptools' distutils
    # import hook, just as Python does for an ordinary installed site directory.
    (venv / relative / "bottled-sage-dependencies.pth").write_text(
        "".join(f"import site; site.addsitedir({entry['path']!r})\n"
                for entry in sites if not entry.get("append_only")))
    write_json(artifacts / "python-sites.json", sites)
    subprocess.run([str(venv / "bin/python"), "-I", __file__, "check-before-build"], check=True)

    archive = root / f"sage-{VERSION}.tar.gz"
    url = f"https://github.com/dimpase/sage/archive/{COMMIT}.tar.gz"
    with urllib.request.urlopen(url) as response, archive.open("wb") as output:
        shutil.copyfileobj(response, output)
    with archive.open("rb") as archive_file:
        digest = hashlib.file_digest(archive_file, "sha256").hexdigest()
    assert digest == ARCHIVE_SHA256, (digest, ARCHIVE_SHA256)
    source = root / f"sage-{VERSION}"
    assert not source.exists(), "Validation requires fresh source"
    with tarfile.open(archive) as bundle:
        bundle.extractall(root, filter="data")
    (root / f"sage-{COMMIT}").rename(source)
    assert (source / "VERSION.txt").read_text().strip() == VERSION
    write_json(artifacts / "source.json", {
        "version": VERSION, "tag_commit": COMMIT, "archive_url": url, "sha256": digest,
    })
    print(f"Verified exact {VERSION} source archive and isolated Python 3.14 environment")


def check_python(root, artifacts, built=False):
    venv = (root / "venv").resolve()
    assert Path(sys.prefix).resolve() == venv, (sys.prefix, venv)
    assert sys.prefix != sys.base_prefix
    assert sys.version_info[:2] == (3, 14)
    sites = json.loads((artifacts / "python-sites.json").read_text())
    allowed = [Path(entry["path"]).resolve(strict=True) for entry in sites]
    # Bottled .pth bridges may use opt symlinks to these same audited sites.
    # Resolve aliases without admitting any additional package directory.
    assert not any(path.endswith("site-packages") and Path(path).resolve() not in allowed
                   and not Path(path).resolve().is_relative_to(venv) for path in sys.path), sys.path
    origins = {}
    for name in MODULES:
        module = importlib.import_module(name)
        path = Path(module.__file__).resolve()
        assert any(path.is_relative_to(site) for site in allowed), (name, path)
        origins[name] = str(path)
    meson = importlib.metadata.distribution("meson")
    meson_site = next(Path(entry["path"]).resolve() for entry in sites if entry["formula"] == "meson")
    assert Path(meson.locate_file("")).resolve() == meson_site
    assert Path(origins["mesonbuild.coredata"]).parent.parent == meson_site
    from mesonbuild import coredata
    from packaging.specifiers import SpecifierSet

    assert meson.version == coredata.version
    assert SpecifierSet(meson.metadata["Requires-Python"]).contains(".".join(map(str, sys.version_info[:3])))
    meson_keg = next(Path(entry["keg"]) for entry in sites if entry["formula"] == "meson")
    meson_cli = subprocess.check_output([str(meson_keg / "bin/meson"), "--version"], text=True).strip()
    assert meson_cli == meson.version
    if built:
        import sage.all
        import sage.version

        assert sage.version.version == VERSION, sage.version.version
        sage_path = Path(sage.all.__file__).resolve()
        assert sage_path.is_relative_to(venv), sage_path
        origins["sage.all"] = str(sage_path)
        for name in FEATURES:
            module = importlib.import_module(f"sage.features.{name}")
            for feature in module.all_features():
                feature.require()
                assert feature.is_present_at_runtime(), feature.name
        from sage.all import GF, RDF, matrix, vector

        for order in (9, 125):
            field_matrix = matrix(GF(order), [[1, 1], [0, 1]])
            assert field_matrix * field_matrix.inverse() == 1
        a = matrix(RDF, [[3, 1], [1, 2]])
        b = vector(RDF, [9, 8])
        assert (a * a.solve_right(b) - b).norm() < 1e-12
        check_data(artifacts)
        check_blas(artifacts)
    else:
        assert importlib.util.find_spec("sage") is None, "Old Sage leaked into the environment"
    from cypari2 import Pari
    from primecountpy import prime_pi

    assert Pari()(101).isprime()
    assert prime_pi(1_000_000) == 78498
    write_json(artifacts / ("python-after-build.json" if built else "python-before-build.json"), {
        "python": sys.version, "prefix": sys.prefix, "sys_path": sys.path,
        "origins": origins,
        "distributions": sorted((d.metadata["Name"], d.version, str(d.locate_file("")))
                                for d in importlib.metadata.distributions()),
    })
    pip = importlib.metadata.distribution("pip")
    assert Path(pip.locate_file("")).resolve().is_relative_to(venv)
    result = subprocess.run([sys.executable, "-I", "-B", "-m", "pip", "check"],
                            check=False, text=True, capture_output=True)
    suffix = "after" if built else "before"
    (artifacts / f"pip-check-{suffix}.log").write_text(result.stdout + result.stderr)
    result.check_returncode()
    print("Python and native-feature provenance checks passed" if built else "Isolated bottle imports passed")


def check_data(artifacts):
    import sage.env
    from sage.features.databases import (
        DatabaseCremona, DatabaseEllcurves, DatabaseGraphs, DatabaseJones,
        DatabaseReflexivePolytopes,
    )

    report = json.loads((artifacts / "bottle-provenance.json").read_text())
    deps = next(row for row in report["formulae"] if row["name"] == report["root"])
    keg = Path(deps["keg"]).resolve(strict=True)
    share = keg.parents[2] / "share"
    assert sage.env.SAGE_DATA_PATH is None
    assert Path(sage.env.SAGE_SHARE) == share
    for feature, relative in (
        (DatabaseCremona("cremona_mini"), "cremona/cremona_mini.db"),
        (DatabaseEllcurves(), "ellcurves/rank0"),
        (DatabaseGraphs(), "graphs/graphs.db"),
        (DatabaseReflexivePolytopes(), "reflexive_polytopes/Full3d"),
    ):
        path = Path(feature.absolute_filename())
        assert path.samefile(share / "sagemath" / relative), path
        assert path.resolve().is_relative_to(keg), path
    # Discovery only: remove this optional-data fixture before the real tests.
    fixture = Path(sage.env.DOT_SAGE) / "db/jones/jones.sobj"
    fixture.parent.mkdir(parents=True, exist_ok=True)
    try:
        fixture.write_text("Data-discovery fixture, not a Jones database.\n")
        assert Path(DatabaseJones().absolute_filename()) == fixture
    finally:
        fixture.unlink(missing_ok=True)


def check_blas(artifacts):
    import numpy
    import scipy

    with (artifacts / "blas-configuration.txt").open("w") as output:
        with contextlib.redirect_stdout(output):
            numpy.show_config()
            scipy.show_config()
        if sys.platform == "darwin":
            for name in ("numpy.linalg._umath_linalg", "scipy.linalg._fblas"):
                extension = importlib.import_module(name)
                linked = subprocess.check_output(["otool", "-L", extension.__file__], text=True)
                output.write(linked)
                assert "Accelerate.framework" in linked, (name, linked)


def run_tests(root, artifacts):
    subprocess.run(["uv", "pip", "install", "--python", sys.executable,
                    "--no-deps", "--no-sources", *TEST_PACKAGES], check=True)
    check_python(root, artifacts, built=True)
    for requirement in TEST_PACKAGES:
        name, version = requirement.split("==")
        dist = importlib.metadata.distribution(name)
        assert dist.version == version
        assert Path(dist.locate_file("")).resolve().is_relative_to(Path(sys.prefix).resolve())
    source = root / f"sage-{VERSION}"
    commands = {"pytest": [sys.executable, "-I", "-m", "pytest", "-q",
                            f"--junitxml={artifacts / 'pytest-results.xml'}"]}
    commands.update({f"doctest-{name}": [sys.executable, "-I", "-m", "sage.doctest",
                                        "--long", "-p2", "--timeout=180", *paths]
                     for name, paths in DOCTEST_GROUPS.items()})
    results = []
    suite = ET.Element("testsuite", name="Sage validation command groups")
    for name, command in commands.items():
        print(f"Starting {name}", flush=True)
        start = time.monotonic()
        log_path = artifacts / f"{name}.log"
        with log_path.open("w") as log:
            completed = subprocess.run(command, cwd=source, stdout=log, stderr=subprocess.STDOUT)
        duration = time.monotonic() - start
        results.append({"name": name, "command": command, "seconds": duration,
                        "exit_code": completed.returncode})
        case = ET.SubElement(suite, "testcase", name=name, time=str(duration))
        if completed.returncode:
            ET.SubElement(case, "failure", message=f"Exit code {completed.returncode}; see {name}.log")
        write_json(artifacts / "test-status.json", results)
        suite.set("tests", str(len(results)))
        suite.set("failures", str(sum(bool(r["exit_code"]) for r in results)))
        ET.ElementTree(suite).write(artifacts / "command-results.xml", encoding="utf-8", xml_declaration=True)
        print("\n".join(log_path.read_text(errors="replace").splitlines()[-35:]), flush=True)
        print(f"{name}: exit {completed.returncode}, {duration:.1f}s", flush=True)
    return int(any(result["exit_code"] for result in results))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("stage", choices=["prepare", "check-before-build", "check-after-build", "test"])
    args = parser.parse_args()
    root = Path(os.environ["VALIDATION_ROOT"]).resolve()
    artifacts = root / "artifacts"
    artifacts.mkdir(parents=True, exist_ok=True)
    if args.stage == "prepare":
        prepare(root, artifacts)
    elif args.stage == "test":
        return run_tests(root, artifacts)
    else:
        check_python(root, artifacts, built=args.stage == "check-after-build")
    return 0


if __name__ == "__main__":
    sys.exit(main())
