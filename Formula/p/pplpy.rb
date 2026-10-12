class Pplpy < Formula
  desc "Python interface to the Parma Polyhedra Library"
  homepage "https://github.com/sagemath/pplpy"
  url "https://files.pythonhosted.org/packages/75/b0/bcda4d51601f4e7dc5d5983972d5947c6c2c9cb943de359f0ba989b1c7ac/pplpy-0.9.0.tar.gz"
  sha256 "8289c50d680ce3f9eacac666cb4cdbbd8a711959e7cc7cf06f7fdb4035d0cc5d"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pplpy-0.9.0"
    sha256 cellar: :any, arm64_tahoe:  "b614eb36ad883e035266932d13ef6e6236f15c6b92dadb8eb6f06265c1ea3ffe"
    sha256 cellar: :any, arm64_linux:  "03d22b777b545b37349c45d3954fb1f6f4d58cd31d4fbe0e4f278b0f85a15a6e"
    sha256 cellar: :any, x86_64_linux: "5b55b304f841690997751b7eb425e96f22368a461a0a552c42f1a03e89401638"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.14" => [:build, :test]
  depends_on "dimpase/tap/cysignals"
  depends_on "dimpase/tap/gmpy2"
  depends_on "gmp"
  depends_on "ppl"

  on_macos do
    depends_on "python@3.13" => [:build, :test]
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/0d/6d/b4752b044bf94cb802d88a888dc7d288baaf77d7910b7dedda74b5ceea0c/setuptools-79.0.1-py3-none-any.whl", using: :nounzip
    sha256 "e147c0549f27767ba362f9da434eab9c5dc0045d5304feb602a0af001089fc51"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl", using: :nounzip
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "pyproject-metadata" do
    url "https://files.pythonhosted.org/packages/b9/8e/d883718e872abc214ba053f60f7e6edc2abd5ffbd1544beb01a9c92ddd3c/pyproject_metadata-0.12.1-py3-none-any.whl", using: :nounzip
    sha256 "f7162d580a96386a8eb096da06215f981f547d1490f03055ef99e323bc2da427"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/2e/29/69cfbb602cd91690c55d38ba9fe53e6a7e76a6fa647bf38f19c138d25449/wheel-0.48.0-py3-none-any.whl", using: :nounzip
    sha256 "3217dcc807155e45db462d7ef2431f5ddda0d7273b700d05a67b271ceb1287ab"
  end

  resource "meson-python" do
    url "https://files.pythonhosted.org/packages/96/62/0c1cf20fe158b0e623e78acbf5fb6de5f1410a408f65f727e4090497627b/meson_python-0.22.1-py3-none-any.whl", using: :nounzip
    sha256 "258fde948cf45aab5df23fcc9e17a9050ee73d4e1002fe6cf86519f61c414778"
  end

  resource "cython" do
    url "https://files.pythonhosted.org/packages/a9/d8/4981ef716ad0e3ff0d3ef383aefc6b03c4a88dee33b272bf8e0d833001ca/cython-3.3.0.tar.gz"
    sha256 "eed0d93fbca7087f143b42c34b05a825849bdf17f101572c2105acfa49aa88b8"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version)
  end

  def install
    inreplace "pyproject.toml", "--default-library=static", "--default-library=shared"
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      site_packages = Language::Python.site_packages(python3)
      build_prefix = buildpath/"build-python#{python.version.major_minor}"
      ENV["PYTHONPATH"] = "#{build_prefix/site_packages}:#{prefix/site_packages}"
      ENV.prepend_path "PATH", build_prefix/"bin"
      resources.each do |r|
        r.stage do
          if r.name == "cython"
            system python3, "-m", "pip", "install", *std_pip_args(prefix: build_prefix), "."
          else
            system python3, "-m", "pip", "install", "--no-deps", "--ignore-installed", "--no-compile",
                   "--prefix=#{build_prefix}", Dir["*.whl"].fetch(0)
          end
        end
      end
      system python3, "-m", "pip", "install", *std_pip_args,
             "-Csetup-args=--wrap-mode=nofallback",
             "-Ccompile-args=-j#{ENV.make_jobs}", "."
    end
  end

  test do
    require "utils/linkage"
    vendor_directories = %w[.libs .dylibs]
    shared_libraries = %w[ppl gmp]
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      package = prefix/Language::Python.site_packages(python3)/"ppl"
      vendor_directories.each do |directory|
        refute_path_exists package/directory
        refute_path_exists package.parent/"pplpy#{directory}"
      end
      assert_empty package.glob("**/*.dylib")
      assert_empty package.glob("**/*.a")
      assert_empty package.glob("**/lib*.so*")
      dylib_ext = OS.mac? ? "dylib" : "so"
      binary = package.glob("polyhedron.*.so").fetch(0)
      shared_libraries.each do |name|
        library = formula_opt_lib(name)/"lib#{name}.#{dylib_ext}"
        assert Utils.binary_linked_to_library?(binary, library), "Missing shared #{name} linkage!"
      end

      system python3, "-c", <<~PYTHON
        import doctest
        import pathlib
        import ppl
        assert pathlib.Path(ppl.__file__).resolve().is_relative_to(pathlib.Path("#{prefix}").resolve())
        for name in ('linear_algebra', 'mip_problem', 'polyhedron', 'generator', 'constraint', 'congruence', 'bit_arrays'):
            module = __import__('ppl.' + name, fromlist=[name])
            result = doctest.testmod(module, optionflags=doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE)
            assert result.failed == 0, (name, result)
        x, y = ppl.Variable(0), ppl.Variable(1)
        poly = ppl.C_Polyhedron(ppl.Constraint_System([x >= 0, y >= 0, x + y == 1]))
        assert poly.affine_dimension() == 1
        assert len(poly.minimized_generators()) == 2
        assert ppl.C_Polyhedron(poly.minimized_generators()) == poly
      PYTHON
    end
  end
end
