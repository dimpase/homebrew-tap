class Libhomfly < Formula
  desc "Compute the homfly polynomial of knots and links"
  homepage "https://github.com/miguelmarco/libhomfly"
  url "https://github.com/miguelmarco/libhomfly/releases/download/1.05/libhomfly-1.05.tar.gz"
  sha256 "371390bd4a18510e34829fcc3e8cebf916e52647515a5088dccffa56f8494919"
  license :public_domain

  depends_on "pkgconf" => :build
  depends_on "bdw-gc"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <homfly.h>
      #include <string.h>
      int main(void) {
        char trefoil[] = "1 6 0 1 1 -1 2 1 0 -1 1 1 2 -1 0 1 1 1 2 1";
        char *polynomial = homfly_str(trefoil);
        return !polynomial || strcmp(polynomial, " - L^-4 - 2L^-2 + M^2L^-2");
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lhomfly", "-o", "test"
    system "./test"
  end
end
