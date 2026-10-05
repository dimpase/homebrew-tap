class Cysignals < Formula
  desc "Interrupt and signal handling for Cython"
  homepage "https://github.com/sagemath/cysignals"
  url "https://files.pythonhosted.org/packages/98/dd/9157e0e6138e395405c7ef56a55b0edcc292e2a9e7f8c90e8b2d912e9a1d/cysignals-1.13.1.tar.gz"
  sha256 "6444b86ddd1f31c7b15e4f0a3dafb973507759676a00f2cc599f0d75062d9eb0"
  license "LGPL-3.0-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]

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

  resource "pyproject-metadata" do
    url "https://files.pythonhosted.org/packages/b9/8e/d883718e872abc214ba053f60f7e6edc2abd5ffbd1544beb01a9c92ddd3c/pyproject_metadata-0.12.1-py3-none-any.whl", using: :nounzip
    sha256 "f7162d580a96386a8eb096da06215f981f547d1490f03055ef99e323bc2da427"
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
             "-Ccompile-args=-j#{ENV.make_jobs}",
             "."
    end
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        from cysignals.tests import test_sig_off, test_sig_on, test_sig_retry
        test_sig_off()
        assert isinstance(test_sig_on(), KeyboardInterrupt)
        assert test_sig_retry() == 10
      PYTHON
    end
  end
end
