class Cvxopt < Formula
  desc "Python software for convex optimization"
  homepage "https://cvxopt.org/"
  url "https://files.pythonhosted.org/packages/3f/b7/0e6ecb45c152029310a0cf7594e518f3591b363d4e06638526efc7872cb8/cvxopt-1.3.3.tar.gz"
  sha256 "8059cef41f1f115c87bc9b75fec9f86db95e7f0afcf03a52d619ba433e443bcb"
  license "GPL-3.0-or-later"

  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "glpk"
  depends_on "suite-sparse"

  on_linux do
    depends_on "openblas"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/0d/6d/b4752b044bf94cb802d88a888dc7d288baaf77d7910b7dedda74b5ceea0c/setuptools-79.0.1-py3-none-any.whl", using: :nounzip
    sha256 "e147c0549f27767ba362f9da434eab9c5dc0045d5304feb602a0af001089fc51"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl", using: :nounzip
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/2e/29/69cfbb602cd91690c55d38ba9fe53e6a7e76a6fa647bf38f19c138d25449/wheel-0.48.0-py3-none-any.whl", using: :nounzip
    sha256 "3217dcc807155e45db462d7ef2431f5ddda0d7273b700d05a67b271ceb1287ab"
  end

  resource "setuptools-scm" do
    url "https://files.pythonhosted.org/packages/ab/ac/8f96ba9b4cfe3e4ea201f23f4f97165862395e9331a424ed325ae37024a8/setuptools_scm-8.3.1-py3-none-any.whl", using: :nounzip
    sha256 "332ca0d43791b818b841213e76b1971b7711a960761c5bea5fc5cdb5196fbce3"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version)
  end

  def install
    ENV["CVXOPT_SUITESPARSE_SRC_DIR"] = ""
    ENV["CVXOPT_SUITESPARSE_INC_DIR"] = formula_opt_include("suite-sparse")/"suitesparse"
    ENV["CVXOPT_SUITESPARSE_LIB_DIR"] = formula_opt_lib("suite-sparse")
    ENV["CVXOPT_BUILD_GLPK"] = "1"
    ENV["CVXOPT_GLPK_INC_DIR"] = formula_opt_include("glpk")
    ENV["CVXOPT_GLPK_LIB_DIR"] = formula_opt_lib("glpk")
    ENV["CVXOPT_BLAS_LIB_DIR"] = OS.mac? ? "/usr/lib" : formula_opt_lib("openblas")
    ENV["CVXOPT_BLAS_LIB"] = OS.mac? ? "blas" : "openblas"
    ENV["CVXOPT_LAPACK_LIB"] = OS.mac? ? "lapack" : "openblas"

    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      site_packages = Language::Python.site_packages(python3)
      build_prefix = buildpath/"build-python#{python.version.major_minor}"
      ENV["PYTHONPATH"] = "#{build_prefix/site_packages}:#{prefix/site_packages}"
      ENV.prepend_path "PATH", build_prefix/"bin"
      resources.each do |r|
        r.stage do
          system python3, "-m", "pip", "install", "--no-deps", "--ignore-installed", "--no-compile",
                 "--prefix=#{build_prefix}", Dir["*.whl"].fetch(0)
        end
      end
      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    require "utils/linkage"
    vendor_directories = %w[.libs .dylibs]
    suitesparse_modules = %w[cholmod umfpack amd]
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      package = prefix/Language::Python.site_packages(python3)/"cvxopt"
      vendor_directories.each do |directory|
        refute_path_exists package/directory
        refute_path_exists package.parent/"cvxopt#{directory}"
      end
      assert_empty package.glob("**/*.dylib")
      assert_empty package.glob("**/*.a")
      assert_empty package.glob("**/lib*.so*")

      dylib_ext = OS.mac? ? "dylib" : "so"
      suitesparse_modules.each do |name|
        binary = package.glob("#{name}.*.so").fetch(0)
        library = formula_opt_lib("suite-sparse")/"lib#{name}.#{dylib_ext}"
        assert Utils.binary_linked_to_library?(binary, library), "Missing shared SuiteSparse linkage in #{name}!"
      end
      binary = package.glob("glpk.*.so").fetch(0)
      library = formula_opt_lib("glpk")/"libglpk.#{dylib_ext}"
      assert Utils.binary_linked_to_library?(binary, library), "Missing shared GLPK linkage!"
      if OS.mac?
        linkage = package.glob("*.so").flat_map { |p| BinaryPathname.wrap(p).dynamically_linked_libraries }.join("\n")
        assert_match "Accelerate.framework", linkage
        refute_match(/openblas/i, linkage)
      else
        binary = package.glob("blas.*.so").fetch(0)
        library = formula_opt_lib("openblas")/"libopenblas.so"
        assert Utils.binary_linked_to_library?(binary, library), "Missing shared OpenBLAS linkage!"
      end

      system python3, "-c", <<~PYTHON
        import pathlib
        import cvxopt
        assert pathlib.Path(cvxopt.__file__).resolve().is_relative_to(pathlib.Path("#{prefix}").resolve())
        from cvxopt import cholmod, glpk, matrix, solvers, spmatrix, umfpack
        a = spmatrix([2.0, 3.0], [0, 1], [0, 1])
        for solver in (cholmod.linsolve, umfpack.linsolve):
            b = matrix([4.0, 9.0])
            solver(a, b)
            assert max(abs(b[0] - 2.0), abs(b[1] - 3.0)) < 1e-7
        c = matrix([1.0, 1.0])
        g = matrix([[-1.0, -2.0, -1.0, 0.0], [-2.0, -1.0, 0.0, -1.0]])
        h = matrix([-3.0, -3.0, 0.0, 0.0])
        solvers.options['show_progress'] = False
        for solver in (None, 'glpk'):
            result = solvers.lp(c, g, h, solver=solver)
            assert result['status'] == 'optimal', result
            assert abs(result['primal objective'] - 2.0) < 1e-7
      PYTHON
    end
  end
end
