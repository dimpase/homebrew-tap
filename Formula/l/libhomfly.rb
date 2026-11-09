class Libhomfly < Formula
  desc "Compute the homfly polynomial of knots and links"
  homepage "https://github.com/miguelmarco/libhomfly"
  url "https://github.com/miguelmarco/libhomfly/releases/download/1.04/libhomfly-1.04.tar.gz"
  sha256 "659a77b4f4b53340d24a7d6a69f4219e77ab9439a6ab8afa0156b7f6bd7af64f"
  license :public_domain

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/libhomfly-1.04"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "d43efb40385aa4d17131a8ac98f290b76afd7fc50b8d2f9744a8c64f1e5a6ccf"
    sha256 cellar: :any, arm64_linux:  "155d88e9ea08d43fd695aa97c7ffbdfbd264d4e8892b5a4f481019b6307a2efe"
    sha256 cellar: :any, x86_64_linux: "272a7fee0daec8f05ad39245c0dec757eb41972b6f30b663f7d91bdef703a4a1"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "bdw-gc"
  depends_on "pkgconf"

  def install
    system "autoreconf", "-ivf"
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
