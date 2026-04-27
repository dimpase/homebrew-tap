class Iml < Formula
  desc "C library for exact solving of dense linear systems over integers"
  homepage "https://www.cs.uwaterloo.ca/~astorjoh/iml.html"
  url "https://www.cs.uwaterloo.ca/~astorjoh/iml-1.0.5.tar.bz2"
  sha256 "1dad666850895a5709b00b97422e2273f293cfadea7697a9f90b90953e847c2a"
  license "GPL-2.0-or-later"

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
