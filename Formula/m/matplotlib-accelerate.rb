class MatplotlibAccelerate < Formula
  desc "Matplotlib using Accelerate on macOS and OpenBLAS on Linux"
  homepage "https://matplotlib.org/"
  url "https://files.pythonhosted.org/packages/e7/c8/9aa712a0afb882649424dd8de8ad9aa6235e796e84c6052e8f6dc1598d0d/matplotlib-3.11.2.tar.gz"
  sha256 "cec596316640f2b394b8f0daa0ea61a8eae82d017b620b9f202befb972a59ea4"
  license "PSF-2.0"
  revision 1

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/matplotlib-accelerate-3.11.2_1"
    sha256 cellar: :any, arm64_tahoe:  "02a89bb0308e07981075253604357b910a6a7085790ae9faa38baf9dcf74e876"
    sha256 cellar: :any, arm64_linux:  "5ed774370436a47290daf1b58be9d927b7b93abbff62c073f7b2d900cf80b6f3"
    sha256 cellar: :any, x86_64_linux: "2a7b8342d88aa62fd62b43e523832870f57b4ba15c29de9ff0c33cf1c9c91844"
  end

  depends_on "cmake" => :build # for contourpy
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "freetype"
  depends_on "pillow" => :no_linkage
  depends_on "python-packaging"
  depends_on "qhull"

  on_macos do
    depends_on "dimpase/tap/numpy-accelerate"
    depends_on macos: :sonoma
  end

  on_linux do
    depends_on "patchelf" => :build
    depends_on "numpy"
  end

  conflicts_with "python-matplotlib", because: "both expose the matplotlib Python module"

  pypi_packages package_name: "matplotlib", exclude_packages: %w[numpy packaging pillow]

  resource "contourpy" do
    url "https://files.pythonhosted.org/packages/83/5a/a55177dd22553a277388e8a1b3220e92de91bacb28356cdc73caa240121d/contourpy-1.4.0.tar.gz"
    sha256 "20156f5a1ac4f8ce02656e39a61e82164a3d359796dc8026f75b062783d500e1"
  end

  resource "cycler" do
    url "https://files.pythonhosted.org/packages/a9/95/a3dbbb5028f35eafb79008e7522a75244477d2838f38cbb722248dabc2a8/cycler-0.12.1.tar.gz"
    sha256 "88bb128f02ba341da8ef447245a9e138fae777f6a23943da4540077d3601eb1c"
  end

  resource "fonttools" do
    url "https://files.pythonhosted.org/packages/77/51/d63c7e52163ac14393a35bd14bd7c0da95f8f74be5d7cc988092f9965129/fonttools-4.65.0.tar.gz"
    sha256 "762ba5431358d0dbd4a01982484a1d494fb267e91f974cdcf20b80eab8560f6f"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/ba/07/bd78e6a8fae171ea041ef5bba3ed21a003522fa088834b069b1909981f30/kiwisolver-1.5.1.tar.gz"
    sha256 "f1303ef2eec81262a4b708c3e858afe58d7c75ad91c1c05266eda7673369859a"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/f3/91/9c6ee907786a473bf81c5f53cf703ba0957b23ab84c264080fb5a450416f/pyparsing-3.3.2.tar.gz"
    sha256 "c777f4d763f140633dcb6d8a3eda953bf7a214dc4eff598413c070bcdc117cbc"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
    sha256 "37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
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
      python_version = Language::Python.major_minor_version(python3)
      private_prefix = libexec/"python#{python_version}"
      ENV["PYTHONPATH"] = "#{private_prefix/site_packages}:#{prefix/site_packages}"

      resources.each do |r|
        r.stage do
          system python3, "-m", "pip", "install",
                 *std_pip_args(prefix: private_prefix, build_isolation: true), "."
        end
      end
      system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true),
             "-Csetup-args=-Dsystem-freetype=true", "-Csetup-args=-Dsystem-qhull=true", "."

      (prefix/site_packages/"dimpase-matplotlib-dependencies.pth").write <<~EOS
        import site; site.addsitedir('#{opt_libexec/"python#{python_version}"/site_packages}')
      EOS
    end
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        import pathlib
        import sys
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        import numpy as np
        from PIL import Image
        installed = pathlib.Path("#{lib}") / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/matplotlib/__init__.py"
        assert installed.samefile(matplotlib.__file__)
        fig, ax = plt.subplots()
        x = np.linspace(0, 2 * np.pi, 100)
        ax.plot(x, np.sin(x))
        fig.savefig("plot.png")
        plt.close(fig)
        with Image.open("plot.png") as image:
            assert image.width > 0 and image.height > 0
        if sys.platform == "darwin":
            import subprocess
            root = pathlib.Path(np.__file__).parent
            linkage = "\\n".join(subprocess.check_output(["otool", "-L", str(p)], text=True)
                                  for p in root.rglob("*.so"))
            assert "Accelerate.framework" in linkage
            assert "openblas" not in linkage.lower()
            assert "libgomp" not in linkage.lower()
      PYTHON
    end
  end
end
