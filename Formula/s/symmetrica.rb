class Symmetrica < Formula
  desc "Collection of C routines for representation theory"
  homepage "https://gitlab.com/sagemath/symmetrica"
  url "https://github.com/sagemath/sage-package/releases/download/tars/symmetrica-3.1.0.tar.xz"
  sha256 "2efc4b1d047c6fe036453882a20e906ca2bedecae888356c7626447db2b10fd3"
  license :public_domain

  depends_on "autoconf" => :build
  depends_on "automake" => :build
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
