class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]
  revision 3

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
    ENV.append "CXXFLAGS", "-std=gnu++17" if OS.linux?
    system "autoreconf", "-ivf"
    system "./configure", "--with-boost=#{HOMEBREW_PREFIX}", "--with-boost-libdir=#{HOMEBREW_PREFIX}/lib",
      "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <polybori/polybori.h>
      #include <m4ri/m4ri.h>
      #include <cassert>
      int main() {
        PBORI::BoolePolyRing ring(3);
        PBORI::BoolePolynomial f = ring.variable(0) + ring.variable(1);
        assert(f * f == f);
        mzd_t *matrix = mzd_init(3, 3);
        mzd_set_ui(matrix, 1);
        assert(mzd_echelonize(matrix, 0) == 3);
        mzd_free(matrix);
      }
    CPP
    flags = shell_output("pkg-config --cflags --libs brial").split
    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{formula_opt_include("boost")}", *flags, "-o", "test"
    system "./test"
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
