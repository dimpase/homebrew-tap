class Gf2x < Formula
  desc "Fast arithmetic in GF(2)[x] and searching for irreducible/primitive trinomials"
  homepage "https://gitlab.inria.fr/gf2x/gf2x"
  url "https://gitlab.inria.fr/gf2x/gf2x/uploads/c46b1047ba841c20d1225ae73ad6e4cd/gf2x-1.3.0.tar.gz"
  sha256 "9472cd651972a1de38e3c4c47697a86e0ecf19d7d33454d4bc2a62bc85841b59"
  license "GPL-2.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  patch :DATA

  def install
    system "autoreconf", "-ivf"
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system "true"
  end
end

__END__


From 5c8737c5c3170358024a4a969e1386cea15932f3 Mon Sep 17 00:00:00 2001
From: Michael Orlitzky <michael@orlitzky.com>
Date: Sun, 26 Apr 2020 09:56:34 -0400
Subject: [PATCH 1/1] src/tunetoom.c: delete duplicate definition of rp.

The "make tune-toom" command has started failing with gcc-10.x because
of its new default -fno-common behavior,

  * https://gcc.gnu.org/gcc-10/porting_to.html
  * https://wiki.gentoo.org/wiki/Gcc_10_porting_notes/fno_common

This leads to an error involving the FILE pointer "rp" that is declared
in global scope in both src/tunetoom.c and src/tuning-common.c. In this
case, the declaration in src/tunetoom.c is simply redundant: that file
includes src/tuning-common.h which already declares "rp" as extern.

Deleting the redeclaration in src/tunetoom.c makes the build succeed.
---
 src/tunetoom.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/src/tunetoom.c b/src/tunetoom.c
index 7553e0c..1140606 100644
--- a/src/tunetoom.c
+++ b/src/tunetoom.c
@@ -111,8 +111,6 @@ const char * gf2x_utoom_select_string[] = {
     [GF2X_SELECT_UNB_TC3U]  = "TC3U",
 };
 
-FILE *rp;
-
 void tunetoom(long tablesz)
 {
     long high, n;
-- 
2.24.1
diff -urN a/config/acinclude.m4 b/config/acinclude.m4
--- a/config/acinclude.m4	2019-12-10 13:27:51.000000000 +0100
+++ b/config/acinclude.m4	2020-09-17 23:27:26.165763845 +0200
@@ -661,6 +661,7 @@
 # remove anything that might look like compiler output to our "||" expression
 rm -f conftest* a.out b.out a.exe a_out.exe
 cat >conftest.c <<EOF
+#include <stdlib.h>
 int
 main ()
 {
@@ -699,6 +700,7 @@
 AC_CACHE_CHECK([for build system executable suffix],
                gf2x_cv_prog_exeext_for_build,
 [cat >conftest.c <<EOF
+#include <stdlib.h>
 int
 main ()
 {
