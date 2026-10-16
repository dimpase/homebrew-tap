class Sagemath < Formula
  desc "Open source mathematics software"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta1.tar.gz"
  sha256 "fc3e2af93024456c3898243a49dcfa721292b85f264c4c3a94c2ed22d3385091"
  license "GPL-2.0-or-later"
  revision 2

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "pybind11" => :build

  # Homebrew requires direct declarations for libraries linked by sagelib,
  # even though sagemath-deps already supplies them.
  depends_on "boost"
  depends_on "dimpase/gap/gap"
  depends_on "dimpase/tap/bliss"
  depends_on "dimpase/tap/brial"
  depends_on "dimpase/tap/cliquer"
  depends_on "dimpase/tap/coxeter3"
  depends_on "dimpase/tap/eclib"
  depends_on "dimpase/tap/gmp-ecm"
  depends_on "dimpase/tap/iml"
  depends_on "dimpase/tap/lcalc"
  depends_on "dimpase/tap/libbraiding"
  depends_on "dimpase/tap/libhomfly"
  depends_on "dimpase/tap/meataxe"
  depends_on "dimpase/tap/pari"
  depends_on "dimpase/tap/planarity"
  depends_on "dimpase/tap/rw"
  depends_on "dimpase/tap/sagemath-deps"
  depends_on "dimpase/tap/sirocco"
  depends_on "dimpase/tap/symmetrica"
  depends_on "ecl"
  depends_on "flint"
  depends_on "gd"
  depends_on "glpk"
  depends_on "gmp"
  depends_on "gsl"
  depends_on "highs"
  depends_on "libmpc"
  depends_on "libomp" if OS.mac?
  depends_on "libpng"
  depends_on "m4ri"
  depends_on "m4rie"
  depends_on "macaulay2/tap/fflas-ffpack"
  depends_on "macaulay2/tap/givaro"
  depends_on "macaulay2/tap/linbox"
  depends_on "mpfi"
  depends_on "mpfr"
  depends_on "ntl"
  depends_on "python@3.14"
  depends_on "singular"

  on_macos do
    depends_on macos: :sonoma
    depends_on "python@3.13"
  end

  on_linux do
    depends_on "binutils" => :build
    depends_on "patchelf" => :build
    depends_on "gcc"
    depends_on "openblas"
    depends_on "zlib-ng-compat"
  end

  # Sage PR #42878: discover the renamed Python data distributions.
  patch do
    url "https://github.com/sagemath/sage/commit/489c311673529a58e208c77583a9f426459993c1.patch?full_index=1"
    sha256 "fcbd6688d7553731c97a80e4cd5482c5915265316e6b03fbe9ee8afbf3400b1e"
  end

  patch do
    url "https://github.com/sagemath/sage/commit/014fec56e64246e83c9ae5a65b5494d89f969adf.patch?full_index=1"
    sha256 "c8efcfa23d1a1b9db3fc7bb4bdab6acec474d0feed88223d5f06d1582d3fe7f8"
  end

  # Sage PR #42920: Sphinx belongs to the optional documentation dependencies.
  patch do
    url "https://github.com/sagemath/sage/commit/6a1d13494fa89f9db30775879adc7ab24dabe1da.patch?full_index=1"
    sha256 "72100f9cbb66486569d788d4e300b9acf82f8a3769f4819158353e16fe926998"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| (f.opt_libexec/"bin/python").to_s }
  end

  def install
    # The tap's MeatAxe formula installs its multiplication tables in lib.
    inreplace "src/sage/env.py",
              'MTXLIB = var("MTXLIB", join(SAGE_SHARE, "meataxe"))',
              "MTXLIB = var(\"MTXLIB\", \"#{formula_opt_lib("dimpase/tap/meataxe")}\")"

    if OS.mac?
      inreplace "src/meson.build", "blas = dependency(blas_order)", "blas = dependency('accelerate')"
    else
      inreplace "src/meson.build", "blas = dependency(blas_order)", "blas = dependency('openblas')"

      # Select the assembler that understands Homebrew GCC's ARM64 directives.
      ENV.append "CFLAGS", "-B#{formula_opt_bin("binutils")}/"
      ENV.append "CXXFLAGS", "-B#{formula_opt_bin("binutils")}/"
    end
    ENV["PARI_DIR"] = formula_opt_prefix("dimpase/tap/pari")
    ENV["BOOST_ROOT"] = formula_opt_prefix("boost")

    setup_args = ["-Dbuild-docs=false", "-Ddefer_feature_checks=true", "--wrap-mode=nofallback"]
    %w[bliss brial coxeter3 eclib libbraiding libhomfly mcqd meataxe rankwidth sirocco tdlib].each do |feature|
      setup_args << "-D#{feature}=enabled"
    end
    setup_args = setup_args.map { |arg| "--config-settings=setup-args=#{arg}" }

    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      private_prefix = formula_opt_libexec("dimpase/tap/sagemath-deps")/"python#{python_version}"
      site_packages = Language::Python.site_packages(python3)
      ENV["PYTHONPATH"] = "#{private_prefix/site_packages}:#{prefix/site_packages}"
      ENV.prepend_path "PATH", private_prefix/"bin"

      system python3, "-m", "pip", "install", *std_pip_args,
             *setup_args,
             "--config-settings=compile-args=-j#{ENV.make_jobs}", "."

      mv bin/"sage", bin/"sage-#{python_version}"
    end
    bin.install_symlink "sage-3.14" => "sage"

    # An external Jupyter server may have its own Python on PATH.
    # Meson's kernel template uses bare "python"; pin the Homebrew interpreter.
    kernel_spec = share/"jupyter/kernels/sagemath/kernel.json"
    spec = JSON.parse(kernel_spec.read)
    spec["argv"][0] = (formula_opt_libexec("python@3.14")/"bin/python").to_s
    File.write(kernel_spec, JSON.pretty_generate(spec))
  end

  def caveats
    <<~EOS
      To use Sage's kernel with an external JupyterLab installation, include
      Homebrew's kernel directory in its search path before starting JupyterLab:
        export JUPYTER_PATH="#{HOMEBREW_PREFIX}/share/jupyter${JUPYTER_PATH:+:$JUPYTER_PATH}"
    EOS
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      import importlib.metadata
      import json
      import pathlib
      import subprocess
      import sys

      import numpy as np
      import matplotlib
      matplotlib.use("Agg")
      import scipy
      from scipy import linalg
      from sage.all import *
      import sage.all
      assert pathlib.Path(sage.all.__file__).resolve().is_relative_to(pathlib.Path("#{prefix}").resolve())
      deps_site = pathlib.Path("#{formula_opt_libexec("dimpase/tap/sagemath-deps")}") / f"python{sys.version_info.major}.{sys.version_info.minor}" / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages"
      for name in ("sympy", "ipykernel", "sagemath-data-graphs"):
          dist = importlib.metadata.distribution(name)
          assert pathlib.Path(dist.locate_file("")).resolve() == deps_site.resolve(), name
      kernel_spec = pathlib.Path("#{share}/jupyter/kernels/sagemath/kernel.json")
      spec = json.loads(kernel_spec.read_text())
      assert spec["argv"][0] == "#{formula_opt_libexec("python@3.14")}/bin/python"
      from jupyter_client import KernelManager
      manager = KernelManager(kernel_name="sagemath")
      manager.kernel_spec_manager.kernel_dirs = [str(kernel_spec.parent.parent)]
      client = None
      try:
          manager.start_kernel()
          client = manager.blocking_client()
          client.start_channels()
          client.wait_for_ready(timeout=120)
          reply = client.execute_interactive("assert factor(123456789).value() == 123456789; print(2^10)", timeout=120)
          assert reply["content"]["status"] == "ok", reply
      finally:
          if client is not None:
              client.stop_channels()
          if manager.has_kernel:
              manager.shutdown_kernel(now=True)
      a = np.array([[3., 1.], [1., 2.]])
      b = np.array([9., 8.])
      assert np.allclose(a @ np.linalg.solve(a, b), b)
      assert np.allclose(a @ linalg.solve(a, b), b)
      assert np.allclose(matrix(RDF, a).solve_right(vector(RDF, b)), [2., 3.])
      t = var("t")
      plot(sin(t), (t, 0, 1)).save("plot.png")
      assert pathlib.Path("plot.png").read_bytes()[:8] == bytes([137, 80, 78, 71, 13, 10, 26, 10])
      installed_matplotlib = pathlib.Path("#{formula_opt_prefix("dimpase/tap/matplotlib-accelerate")}") / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/matplotlib/__init__.py"
      assert installed_matplotlib.samefile(matplotlib.__file__), matplotlib.__file__
      if sys.platform == "darwin":
          for package in (np, scipy):
              root = pathlib.Path(package.__file__).parent
              formula = {"numpy": "numpy-accelerate", "scipy": "scipy-accelerate"}[package.__name__]
              installed = pathlib.Path("#{HOMEBREW_PREFIX}/opt") / formula / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages" / package.__name__ / "__init__.py"
              assert installed.samefile(package.__file__), root
              libraries = list(root.rglob("*.so")) + list(root.rglob("*.dylib"))
              linkage = "\\n".join(subprocess.check_output(["otool", "-L", str(p)], text=True)
                                  for p in libraries)
              assert "Accelerate.framework" in linkage, package.__name__
              assert "openblas" not in linkage.lower(), package.__name__
              assert "libgomp" not in linkage.lower(), package.__name__
      assert factor(123456789).value() == 3**2 * 3607 * 3803
      R = PolynomialRing(QQ, "x")
      x = R.gen()
      assert (x**2 - 1).factor().value() == x**2 - 1
      assert GF(16).multiplicative_generator().multiplicative_order() == 15
      for field in (GF(2), GF(16, "a")):
          a = matrix(field, [[1, 1], [0, 1]])
          assert a * a.inverse() == 1
      assert EllipticCurve([0, -1, 1, -10, -20]).rank(algorithm="mwrank_lib") == 0
      assert gap.SmallGroup(24, 3).Size().sage() == 24
      assert pari(2).isprime()
      eigenvalues = matrix(RealField(53), [[0, 1], [-2, 0]]).eigenvalues(algorithm="pari")
      assert all(abs(abs(z.imag()) - sqrt(2.0)) < 1e-12 for z in eigenvalues)
      assert maxima("2+2").sage() == 4
      assert BooleanPolynomialRing(3, "a").ngens() == 3
      from sage.libs.lrcalc.lrcalc import lrcoef, mult
      assert lrcoef([3, 2, 1], [2, 1], [2, 1]) == 2
      assert mult([1], [1]) == {Partition([2]): 1, Partition([1, 1]): 1}
      import cvxopt
      installed_cvxopt = pathlib.Path("#{formula_opt_prefix("dimpase/tap/cvxopt")}") / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/cvxopt/__init__.py"
      assert installed_cvxopt.samefile(cvxopt.__file__), cvxopt.__file__
      from cvxopt import cholmod, matrix as cvx_matrix, spmatrix
      a = spmatrix([2.0, 3.0], [0, 1], [0, 1])
      b = cvx_matrix([4.0, 9.0])
      cholmod.linsolve(a, b)
      assert max(abs(b[0] - 2.0), abs(b[1] - 3.0)) < 1e-7
      for solver in ("CVXOPT", "PPL"):
          p = MixedIntegerLinearProgram(maximization=False, solver=solver)
          v = p.new_variable(real=True, nonnegative=True)
          p.set_objective(v[0] + v[1])
          p.add_constraint(v[0] + 2*v[1] >= 3)
          p.add_constraint(2*v[0] + v[1] >= 3)
          assert abs(p.solve() - 2.0) < 1e-7
      import ppl
      installed_ppl = pathlib.Path("#{formula_opt_prefix("dimpase/tap/pplpy")}") / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/ppl/__init__.py"
      assert installed_ppl.samefile(ppl.__file__), ppl.__file__
      poly = Polyhedron(vertices=[(0, 0), (1, 0), (0, 1)], backend="ppl")
      assert poly.n_vertices() == 3 and poly.dim() == 2
      assert poly.contains((QQ(1)/4, QQ(1)/4))
      assert not poly.contains((1, 1))
      from sage.features.databases import DatabaseCremona, DatabaseGraphs, DatabaseReflexivePolytopes
      assert DatabaseCremona("cremona_mini").is_present()
      assert DatabaseGraphs().is_present()
      assert DatabaseReflexivePolytopes().is_present()
    PYTHON
    pythons.each do |python3|
      system python3, testpath/"test.py"
    end
    assert_equal "4", shell_output("#{bin}/sage -c 'print(2+2)'").strip
  end
end
