class Iml < Formula
  desc "C library for exact solving of dense linear systems over integers"
  homepage "https://www.cs.uwaterloo.ca/~astorjoh/iml.html"
  url "https://www.cs.uwaterloo.ca/~astorjoh/iml-1.0.5.tar.bz2"
  sha256 "1dad666850895a5709b00b97422e2273f293cfadea7697a9f90b90953e847c2a"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/iml-1.0.5"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:  "ada1be6e75ac653ad3e5924efd96f971969e0c41010e7aeb2bb850ea4e2dae9b"
    sha256 cellar: :any,                 sequoia:      "fcb16f757f0518dccc847978003929ba6cfb38dd1cdb83ca813a6aa5a3e9f6bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1d6717b311c299a200271d865b40865121227b37c3482a030bb4976c0f81c000"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "openblas" unless OS.mac?

  patch :DATA

  def install
    blib = ""
    blib << "-framework Accelerate" if OS.mac?
    blib << "-lopenblas" unless OS.mac?
    system "autoreconf", "-ivf"
    system "./configure", "--enable-shared", "--with-default=#{HOMEBREW_PREFIX}",
           "--with-cblas=#{blib}",
           "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gmp.h>
      #include <iml.h>
      #include <stdlib.h>
      #define D 5
      int main(void) {
        mpz_t *A, *B, *p;
        long int d, i;
        A = calloc(D*D, sizeof(mpz_t));
        p = A;
        for (i=0; i<D*D; i++) mpz_init_set_si(*(p++), 1+i+i*i);
        d = nullspaceMP(D, D, A, &B);
        free(A); free(B);
        return d!=2;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{Formula["gmp"].lib}", "-lgmp", "-L#{lib}", "-liml", "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/src/Makefile.am b/src/Makefile.am
index 4514277..8416bf3 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -37,4 +37,4 @@ libiml_la_SOURCES = basisop.c \
 libiml_la_CFLAGS = $(AM_CFLAGS)
 libiml_la_LIBADD = $(EXTERNLIB)
 libiml_la_LDFLAGS = -version-info $(LIBIML_LT_CURRENT):$(LIBIML_LT_REVISION):$(LIBIML_LT_AGE) \
-                    $(LIBIML_LDFLAGS)
+                    -no-undefined $(LIBIML_LDFLAGS)
