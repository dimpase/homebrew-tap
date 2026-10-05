class Cypari2 < Formula
  desc "Python interface to PARI/GP"
  homepage "https://github.com/sagemath/cypari2"
  # Pinned unreleased snapshot supporting PARI 2.19 and explicit pari_prefix.
  url "https://github.com/sagemath/cypari2/archive/3d7553e63d88ccafc445fa5cf577dad65a056d88.tar.gz"
  version "2.2.6"
  sha256 "cffe0c4c54f3b1cd97cceb8f91bb6c3ac2afe5a872193d40cdbc9a0f318ea91e"
  license "GPL-2.0-or-later"

  livecheck do
    skip "Pinned unreleased snapshot for PARI 2.19 compatibility"
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/cypari2-2.2.6"
    sha256 cellar: :any, arm64_tahoe:  "7662bc67498aa0dc87b297f6bb5f6949b141d4def542aed29616d94184433946"
    sha256 cellar: :any, arm64_linux:  "d1718d2715d53237cac32e5cfcb17f6decbedf4c3f3a7b1d7672b28941267976"
    sha256 cellar: :any, x86_64_linux: "42119e30548b2f7a8eaf16ed0f35a6ce89f8af680dc9b258e4bd7de80daefc08"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "dimpase/tap/cysignals"
  depends_on "dimpase/tap/pari"
  depends_on "gmp"

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
             "-Csetup-args=-Dpari_prefix=#{formula_opt_prefix("dimpase/tap/pari")}",
             "-Ccompile-args=-j#{ENV.make_jobs}",
             "."
    end
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        from cypari2 import Pari
        pari = Pari()
        assert pari(2**127 - 1).isprime()
        assert pari("znprimroot(1009)").znorder() == 1008
        assert pari("hyperellcharpoly(t^3 + ffgen(23^3, 'z)*t + 4)") == pari("x^2 - 11*x + 12167")
        assert abs(float(pari("lfun(ellinit([0,0,0,1,2]),1000)")) - 1) < 1e-8
      PYTHON
    end
  end
end
