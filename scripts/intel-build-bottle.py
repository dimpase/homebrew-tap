#!/usr/bin/env python3
"""Build an artifact on the persistent Intel host, restoring its tap checkout."""
import argparse, fcntl, hashlib, json, os, pathlib, platform, re, shutil, signal, subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--formula", required=True)
parser.add_argument("--source-sha", required=True)
parser.add_argument("--output", required=True)
args = parser.parse_args()
if not re.fullmatch(r"[a-z0-9][a-z0-9+@._-]*", args.formula):
    parser.error("Use a formula name from dimpase/tap, without a tap prefix")
if not re.fullmatch(r"[0-9a-f]{40}", args.source_sha):
    parser.error("source-sha must be a full commit SHA")
if platform.system() != "Darwin" or platform.machine() != "x86_64":
    parser.error("This workflow requires Intel macOS")
if subprocess.check_output(["sw_vers", "-productVersion"], text=True).split(".")[0] != "15":
    parser.error("This workflow requires macOS 15")
if subprocess.check_output(["brew", "--prefix"], text=True).strip() != "/usr/local":
    parser.error("This workflow requires the /usr/local Homebrew prefix")

output = pathlib.Path(args.output).resolve()
output.mkdir(parents=True, exist_ok=True)
env = dict(os.environ, HOMEBREW_NO_AUTO_UPDATE="1", HOMEBREW_NO_ANALYTICS="1",
           HOMEBREW_NO_INSTALL_CLEANUP="1", HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK="1",
           HOMEBREW_NO_ENV_HINTS="1", HOMEBREW_NO_INSTALL_FROM_API="1", HOMEBREW_MAKE_JOBS="4")
formula = "dimpase/tap/" + args.formula
scripts = pathlib.Path(__file__).resolve().parent

def run(command, log=None, cwd=None):
    print("$ " + " ".join(command), flush=True)
    result = subprocess.run(command, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if log:
        (output / log).write_text(result.stdout)
    if result.returncode:
        print(result.stdout[-10000:], flush=True)
        raise subprocess.CalledProcessError(result.returncode, command)
    return result.stdout

def interrupted(signum, frame):
    raise SystemExit(128 + signum)

for sig in (signal.SIGTERM, signal.SIGINT):
    signal.signal(sig, interrupted)

lock_path = pathlib.Path.home() / ".cache/intel-bottle-builder.lock"
lock_path.parent.mkdir(parents=True, exist_ok=True)
with lock_path.open("a") as lock:
    print("Waiting for the shared Homebrew build lock", flush=True)
    fcntl.flock(lock, fcntl.LOCK_EX)
    if shutil.disk_usage("/usr/local").free < 10 * 1024**3:
        raise RuntimeError("Less than 10 GiB free; clear space before building")
    tap = pathlib.Path(run(["brew", "--repository", "dimpase/tap"]).strip())
    if run(["git", "-C", str(tap), "status", "--porcelain"]).strip():
        raise RuntimeError("Installed dimpase/tap has local changes; refusing to replace them")
    old_sha = run(["git", "-C", str(tap), "rev-parse", "HEAD"]).strip()
    branch_result = subprocess.run(["git", "-C", str(tap), "symbolic-ref", "--quiet", "--short", "HEAD"],
                                   text=True, capture_output=True)
    old_ref = branch_result.stdout.strip() or old_sha
    changed_checkout = False
    try:
        run(["git", "-C", str(tap), "fetch", "--no-tags", "https://github.com/dimpase/homebrew-tap.git", args.source_sha])
        run(["git", "-C", str(tap), "checkout", "--detach", args.source_sha])
        changed_checkout = True
        metadata = json.loads(run(["brew", "info", "--json=v2", formula], "formula-info.json"))["formulae"][0]
        if metadata["tap"] != "dimpase/tap":
            raise RuntimeError("Formula must belong to dimpase/tap")
        run(["brew", "config"], "brew-config.log")
        run(["brew", "list", "--versions"], "installed-before.log")
        provenance = {}
        for tap_name in ("homebrew/core", "dimpase/tap", "macaulay2/tap", "dimpase/gap"):
            tap_path = pathlib.Path(run(["brew", "--repository", tap_name]).strip())
            if (tap_path / ".git").exists():
                provenance[tap_name] = run(["git", "-C", str(tap_path), "rev-parse", "HEAD"]).strip()
        (output / "tap-commits.json").write_text(json.dumps(provenance, indent=2))
        cellar = pathlib.Path(run(["brew", "--cellar"]).strip())
        rack = cellar / args.formula
        backup = output / "installed-receipts-before"
        backup.mkdir(exist_ok=True)
        if rack.exists():
            for receipt in rack.glob("*/INSTALL_RECEIPT.json"):
                shutil.copy2(receipt, backup / (receipt.parent.name + ".json"))
        run(["brew", "install", "--only-dependencies", "--include-test", formula], "dependencies.log")
        run(["brew", "ruby", str(scripts / "rebuild-bottle.rb"), formula], "build.log")
        run(["brew", "linkage", "--test", formula], "linkage.log")
        run(["brew", "test", formula], "test.log")
        version = run(["brew", "ruby", "-e", "puts Formula[ARGV.fetch(0)].pkg_version", formula]).strip()
        url = "https://github.com/dimpase/homebrew-tap/releases/download/" + args.formula + "-" + version
        run(["brew", "bottle", "--json", "--root-url=" + url, formula], "bottle.log", cwd=output)
        bottles = list(output.glob("*.bottle*.tar.gz"))
        json_files = list(output.glob("*.bottle.json"))
        if len(bottles) != 1 or len(json_files) != 1:
            raise RuntimeError("Expected exactly one bottle archive and one bottle JSON")
        data = json.loads(json_files[0].read_text())
        entry = next(iter(data.values()))
        tag = entry["bottle"]["tags"].get("sequoia")
        sha = hashlib.sha256(bottles[0].read_bytes()).hexdigest()
        if not tag or tag["sha256"] != sha:
            raise RuntimeError("Sequoia bottle tag or checksum verification failed")
        receipt = json.loads((rack / version / "INSTALL_RECEIPT.json").read_text())
        manifest = {"formula": formula, "pkg_version": version, "source_commit": args.source_sha,
                    "tap_commits": provenance, "bottle": bottles[0].name, "sha256": sha,
                    "bottle_tag": "sequoia", "prefix": "/usr/local", "cellar": entry["bottle"]["cellar"],
                    "runtime_dependencies": receipt["runtime_dependencies"], "built_on": receipt["built_on"],
                    "linkage_test": "passed", "formula_test": "passed",
                    "clean_environment_pour": "not performed", "publication": "Actions artifact only"}
        (output / "manifest.json").write_text(json.dumps(manifest, indent=2))
        run(["brew", "list", "--versions"], "installed-after.log")
        print("Built and tested " + bottles[0].name, flush=True)
    finally:
        if changed_checkout:
            run(["git", "-C", str(tap), "checkout", old_ref], "tap-restore.log")
            if run(["git", "-C", str(tap), "rev-parse", "HEAD"]).strip() != old_sha:
                raise RuntimeError("Original tap commit was not restored")
