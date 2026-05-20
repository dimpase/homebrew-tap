class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]
  revision 2

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/brial-1.2.15_1"
    sha256 cellar: :any,                 arm64_tahoe:  "5e3499d91c81cc1221d1e4372858bf45e6b29afb1360ce7fd96d4511f64826bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ca5a28a81985332e55ee69534b6506232785adf37704dba264c79cc6ceb7a847"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "boost"
  depends_on "libomp" if OS.mac?
  depends_on "libpng"
  depends_on "m4ri"
  depends_on "pkgconf"

  patch :DATA

  def install
    system "autoreconf", "-ivf"
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--with-boost=#{HOMEBREW_PREFIX}", "--with-boost-libdir=#{HOMEBREW_PREFIX}/lib",
      "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "true"
  end
end

__END__


diff --git a/configure.ac b/configure.ac
index f8953244..5a563134 100644
--- a/configure.ac
+++ b/configure.ac
@@ -36,10 +36,18 @@ AX_BOOST_BASE([1.58.0],[],
 dnl Check that the boost unit test framework is present for running the testsuite
 AX_BOOST_UNIT_TEST_FRAMEWORK
 
+AC_MSG_CHECKING([for debugging being enabled])
 AC_ARG_ENABLE([debug],
               [AS_HELP_STRING([--enable-debug],
                               [enable extra debugging statements in BRiAl's code [default=no]])],
-              [AC_DEFINE([PBORI_DEBUG],[],[enable extra debugging statements])])
+              [if test "$enableval" = "yes"; then
+                   AC_DEFINE([PBORI_DEBUG],[],[enable extra debugging statements])
+                   AC_MSG_RESULT([yes])
+               else
+                   AC_MSG_RESULT([no])
+               fi
+              ], [AC_MSG_RESULT([no])])
+
 AC_ARG_WITH([pkgconfigdir], AS_HELP_STRING([--with-pkgconfigdir=PATH],
 	[Path to the pkgconfig directory [[LIBDIR/pkgconfig]]]),
 	[pkgconfigdir="$withval"], [pkgconfigdir='${libdir}/pkgconfig'])
