class NumpyAccelerate < Formula
  desc "NumPy with Apple Accelerate for Python"
  homepage "https://numpy.org/"
  version "2.5.3"
  license "BSD-3-Clause"

  if Homebrew::SimulateSystem.current_arch == :arm
    url "https://files.pythonhosted.org/packages/94/75/4640d2d6e4b64a049e48425a82728a41ef4adb61332d2cba68055774878b/numpy-2.5.3-cp314-cp314-macosx_14_0_arm64.whl", using: :nounzip
    sha256 "adc1ada2662f8a5f960b8a10d9986897e7499ef07e06d4cfe7197f8cce923c07"
  else
    url "https://files.pythonhosted.org/packages/96/cd/625b57ae33d4ca560f32cc0b47b4a5922146d9beb998ddf773900d440a73/numpy-2.5.3-cp314-cp314-macosx_14_0_x86_64.whl", using: :nounzip
    sha256 "54a115e5a73b8fc44f0cebef486365a1894b5c9760685d4558b72b7c3eb846e0"
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/numpy-accelerate-2.5.3"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "da6c5ca8ba32becf8433a917d7c9aaeb125f5239cb2bc95a9d01d2257bcae83e"
  end

  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on :macos
  on_macos do
    depends_on macos: :sonoma

    # The main download is for Python 3.14; this resource supplies Python 3.13.
    resource "NumPy" do
      version "2.5.3"
      on_arm do
        url "https://files.pythonhosted.org/packages/ab/2a/98282aa5b8f58b1157d440bb6282eed47e3632a5de53a714fbab17e659fe/numpy-2.5.3-cp313-cp313-macosx_14_0_arm64.whl", using: :nounzip
        sha256 "f9a2353b37a1a9e78fd82b27ad7e2a32a2d036604d18f02b05e3136c62ca3b09"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/a1/f9/b6533d777be9d6ffd29dc1be0867e563e6e8cc9a220ff1b716adc317f060/numpy-2.5.3-cp313-cp313-macosx_14_0_x86_64.whl", using: :nounzip
        sha256 "ccbc4665079665c3cf3bab4db9f6b095370cd6437d66be549b6c2a1fd19e1958"
      end
    end
  end

  conflicts_with "numpy", because: "both install the same Python modules and executables"

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
        resource("NumPy").stage { install_wheel(python3) }
      else
        install_wheel(python3)
      end
    end
  end

  def caveats
    <<~EOS
      To run `f2py`, you may need to `brew install #{pythons.last}`
    EOS
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~PYTHON
        import pathlib
        import subprocess
        import sys
        import numpy as np
        a = np.array([[3., 1.], [1., 2.]])
        b = np.array([9., 8.])
        assert np.allclose(a @ np.linalg.solve(a, b), b)
        root = pathlib.Path(np.__file__).parent
        installed = pathlib.Path("#{lib}") / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages/numpy/__init__.py"
        assert installed.samefile(np.__file__), root
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
