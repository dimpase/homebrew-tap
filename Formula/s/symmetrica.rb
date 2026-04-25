class Symmetrica < Formula
  desc "Collection of C routines for representation theory"
  homepage "https://gitlab.com/sagemath/symmetrica"
  url "https://github.com/sagemath/sage-package/releases/download/tars/symmetrica-3.1.0.tar.xz"
  sha256 "2efc4b1d047c6fe036453882a20e906ca2bedecae888356c7626447db2b10fd3"
  license :public_domain

  bottle do
    root_url "https://ghcr.io/v2/dimpase/tap"
    sha256 cellar: :any,                 arm64_tahoe:  "8732abdd95b94a592f487d66c2b40f2ff5ce4c3970e38a510343662a70095754"
    sha256 cellar: :any,                 sequoia:      "06fe06755f44b26a35f2ffdac1ca32d155e29f20b58ff4202b49e61c6c3bec6c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e711da4491311483d99ed2065cb3d87a1dd94783721f90d624f25d8a9a11facd"
  end

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
