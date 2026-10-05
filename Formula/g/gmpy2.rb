class Gmpy2 < Formula
  desc "Python interface to GMP, MPFR, and MPC"
  homepage "https://github.com/gmpy2/gmpy2"
  url "https://files.pythonhosted.org/packages/03/47/5c59682cd4d94291382f447dbe1f6229c8b8a144aa85d32d38ecaf8cfb73/gmpy2-2.3.1.tar.gz"
  sha256 "313f35e9fe6b9ddf72759b14dac25166fe5757c970403e4bbf87a70ab2be07df"
  license "LGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/gmpy2-2.3.1"
    sha256 cellar: :any, arm64_tahoe:  "78862ac08597d7c38a93eded13d2820df199307d4601990e84e94bfd92c4452b"
    sha256               arm64_linux:  "f89752a64e8738228c30c67d40766bd95c819e91918114c5b5437aed5bae43e8"
    sha256               x86_64_linux: "c06de45feebbac19bc66554368927a1c0773b8bea4b4c82acf5ef6c6483eca03"
  end

  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

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
    %w[gmp mpfr libmpc].each do |name|
      ENV.append "CPPFLAGS", "-I#{formula_opt_include(name)}"
      ENV.append "LDFLAGS", "-L#{formula_opt_lib(name)}"
    end
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
      system python3, "-m", "pip", "install", *std_pip_args,
             "."
    end
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        import gmpy2
        assert gmpy2.is_prime(2**127 - 1)
        with gmpy2.context(precision=200):
            assert abs(gmpy2.sqrt(gmpy2.mpfr(2))**2 - 2) < gmpy2.mpfr(2)**-190
            assert abs(gmpy2.sqrt(gmpy2.mpc(-1))**2 + 1) < gmpy2.mpfr(2)**-190
      PYTHON
    end
  end
end
