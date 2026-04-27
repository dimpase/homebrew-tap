class Symmetrica < Formula
  desc "Collection of C routines for representation theory"
  homepage "https://gitlab.com/sagemath/symmetrica"
  url "https://github.com/sagemath/sage-package/releases/download/tars/symmetrica-3.1.0.tar.xz"
  sha256 "2efc4b1d047c6fe036453882a20e906ca2bedecae888356c7626447db2b10fd3"
  license :public_domain

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/symmetrica-3.1.0"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:  "6df1998999175c55e36e978732044f0d88115053f9b9d898f2ab8b4a1606b9c1"
    sha256 cellar: :any,                 sequoia:      "615cdeee7f43596317af3cbdd24a1c825e6465194bf4adebf2d4ea3d4329fe44"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6a733c1b677feda97abac67aa960d632a0b7b350109ef2fa0a86a458f94cd7a9"
  end

  depends_on "libtool" => :build

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <symmetrica.h>

      int main(int argc, char** argv) {
        anfang();

        OP a = callocobject();
        m_i_i(2, a);

        int result = (eq(a, cons_zwei) ? 0 : 1);

        freeall(a);
        ende();
        return result;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lsymmetrica", "-lm", "-o", "test"
    system "./test"
  end
end
