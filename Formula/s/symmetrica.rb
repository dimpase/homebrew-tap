class Symmetrica < Formula
  desc "Collection of C routines for representation theory"
  homepage "https://gitlab.com/sagemath/symmetrica"
  url "https://github.com/sagemath/sage-package/releases/download/tars/symmetrica-3.1.0.tar.xz"
  sha256 "2efc4b1d047c6fe036453882a20e906ca2bedecae888356c7626447db2b10fd3"
  license :public_domain

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/symmetrica-3.1.0"
    rebuild 2
    sha256 cellar: :any, arm64_tahoe:  "f015b92135bda47fa12ccf4be8395f2519a5bdb1d05fd6ff96394a92c41a3891"
    sha256 cellar: :any, arm64_linux:  "d5bfc505c2d0c64bc73b1f8bbfabf44fb7b9f07445b62da71e566850406180fe"
    sha256 cellar: :any, x86_64_linux: "2414a57880a2dc1e5a50663d2a4843bb00f9ab29a214d7ba9585542160628a5a"
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
