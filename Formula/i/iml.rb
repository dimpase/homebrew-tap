class Iml < Formula
  desc "C library for exact solving of dense linear systems over integers"
  homepage "https://www.cs.uwaterloo.ca/~astorjoh/iml.html"
  url "https://www.cs.uwaterloo.ca/~astorjoh/iml-1.0.5.tar.bz2"
  sha256 "1dad666850895a5709b00b97422e2273f293cfadea7697a9f90b90953e847c2a"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/iml-1.0.5"
    sha256 cellar: :any,                 arm64_tahoe:  "69d5702816e0a371ea4d4fb3b8d749b40217ae558c73263f4ffe5fc179955b2b"
    sha256 cellar: :any,                 sequoia:      "9256dc4043ea434da41783ef84d0639091923877222dae3da058fa78d0b301cc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1024f70368a5bed23f06714caa638975685b39c20e385b2892a9c5a5dc4f8a50"
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
    system "true"
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
