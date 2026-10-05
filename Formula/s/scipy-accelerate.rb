class ScipyAccelerate < Formula
  desc "SciPy with Apple Accelerate for Python"
  homepage "https://scipy.org/"
  version "1.18.1"
  license "BSD-3-Clause"

  if Homebrew::SimulateSystem.current_arch == :arm
    url "https://files.pythonhosted.org/packages/70/e8/6b0c288c50942d78193696c9f15f9a0874f5178aa0ddf40f83d9924b3e8d/scipy-1.18.1-cp314-cp314-macosx_14_0_arm64.whl", using: :nounzip
    sha256 "011413b7426b75012840e35649e00fe0a2c3bae89fed433876e3a99251572efc"
  else
    url "https://files.pythonhosted.org/packages/4b/e0/54fd3793c729e3b936782f181b59cbb1205bf250ab605a16cb1ba61cdd5e/scipy-1.18.1-cp314-cp314-macosx_14_0_x86_64.whl", using: :nounzip
    sha256 "88f0e784020649f88ea48c9f5ddfa403bf9205820667c0914740b392035afb82"
  end

  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "dimpase/tap/numpy-accelerate"

  depends_on :macos

  on_macos do
    depends_on macos: :sonoma

    # The main download is for Python 3.14; this resource supplies Python 3.13.
    resource "SciPy" do
      version "1.18.1"
      on_arm do
        url "https://files.pythonhosted.org/packages/9a/d7/21d890274f75ea37a8209d5519e72da3da90302e3b9fb8397a0918386a62/scipy-1.18.1-cp313-cp313-macosx_14_0_arm64.whl", using: :nounzip
        sha256 "ea324d9dd34c38bfb9bec8ca4d1b407db97dbb74029f566b8e322b1b6fe56fe6"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/ec/01/798430ecea2e78ec7c02663d5f71c007bb6abeca931080debd40d7fa55ea/scipy-1.18.1-cp313-cp313-macosx_14_0_x86_64.whl", using: :nounzip
        sha256 "75b00eb8fb802090aa903f4ea1c7f5a584779f967361e68b7e98e531cc2d7174"
      end
    end
  end

  conflicts_with "scipy", because: "both install the same Python modules"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version)
  end

  def install_wheel(python3)
    system python3, "-m", "pip", "install", "--no-deps", "--ignore-installed", "--no-compile",
           "--prefix=#{prefix}", Dir["*.whl"].fetch(0)
  end

  def install
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      python_version = Language::Python.major_minor_version(python3)
      if python_version == "3.13"
        resource("SciPy").stage { install_wheel(python3) }
      else
        install_wheel(python3)
      end
    end
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        import pathlib
        import subprocess
        import sys
        import numpy as np
        import scipy
        from scipy import linalg
        a = np.array([[3., 1.], [1., 2.]])
        b = np.array([9., 8.])
        assert np.allclose(a @ linalg.solve(a, b), b)
        root = pathlib.Path(scipy.__file__).parent
        installed = pathlib.Path("#{lib}") / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/scipy/__init__.py"
        assert installed.samefile(scipy.__file__), root
        if sys.platform == "darwin":
            libraries = list(root.rglob("*.so")) + list(root.rglob("*.dylib"))
            linkage = "\\n".join(subprocess.check_output(["otool", "-L", str(p)], text=True)
                                for p in libraries)
            assert "Accelerate.framework" in linkage
            assert "openblas" not in linkage.lower()
            assert "libgomp" not in linkage.lower()
      PYTHON
    end
  end
end
