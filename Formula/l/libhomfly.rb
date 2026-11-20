class Libhomfly < Formula
  desc "Compute the homfly polynomial of knots and links"
  homepage "https://github.com/miguelmarco/libhomfly"
  url "https://github.com/miguelmarco/libhomfly/releases/download/1.05/libhomfly-1.05.tar.gz"
  sha256 "371390bd4a18510e34829fcc3e8cebf916e52647515a5088dccffa56f8494919"
  license :public_domain

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/libhomfly-1.05"
    sha256 cellar: :any, arm64_tahoe:  "0a53f06dec55695693692c59aa0b754f6f488c7871ece0c0c38b9d30e4427fb0"
    sha256 cellar: :any, arm64_linux:  "c08c068d06ab6b9dabf6f1ac70497351361f45d76f9e6f677deb99b324fa2589"
    sha256 cellar: :any, x86_64_linux: "1dde7d8b8cf616a832d3fa1ed0273d25408d180839b61d3a60d5dd51f7659887"
  end

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
