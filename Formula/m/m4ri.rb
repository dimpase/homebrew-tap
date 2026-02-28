class M4ri < Formula
  desc "M4RI is a library for fast arithmetic with dense matrices over GF(2)"
  homepage "https://github.com/malb/m4ri"
  url "https://github.com/malb/m4ri/releases/download/20260122/m4ri-20260122.tar.gz"
  sha256 "7e033ca1fd36be8861e2f67d9d124c398fc0d830209bb0226462485876346404"
  license "GPL-2.0"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libpng"
  depends_on "libomp" if OS.mac?

  patch :DATA

  def install
    if OS.mac?
      libomp = Formula["libomp"]
      ENV["OPENMP_CFLAGS"] = "-Xpreprocessor -fopenmp -I#{libomp.opt_include} -L#{libomp.opt_lib} -lomp"
    else
      ENV["OPENMP_CFLAGS"] = "-fopenmp"
    end
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--enable-openmp", "--disable-silent-rules", *std_configure_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    if OS.mac?
      require "utils/linkage"
      libgomp = Formula["gcc"].opt_lib/"gcc/current/libgomp.dylib"
      libomp = Formula["libomp"].opt_lib/"libomp.dylib"
      refute Utils.binary_linked_to_library?(lib/"libm4ri.dylib", libgomp), "Unwanted linkage to libgomp!"
      assert Utils.binary_linked_to_library?(lib/"libm4ri.dylib", libomp), "Missing linkage to libomp!"
    end

    (testpath/"test.c").write <<~EOS
/* from https://gist.githubusercontent.com/malb/5afc443d6ca3e212eb28db5c17522ceb/raw/08c7191e71a11dee922126a0a20a4d4ab2dfe6a1/test.c */
#include <m4ri/m4ri.h>
/*

  compile with:

  gcc test.c -lm4ri -lm -o test

 */

const size_t m = 1024;
const size_t n = 1024;
const size_t l = 1024;

int main(int argc, char *argv[]) {
  mzd_t *A = mzd_init(m, n);
  mzd_randomize(A);
  mzd_t *B = mzd_init(m, n);
  mzd_randomize(B);
  mzd_t *C = mzd_init(n, l);
  mzd_randomize(C);

  // AC + BC = (A+B)C
  mzd_t *R0 = mzd_mul(NULL, A, C, 0);
  mzd_addmul(R0, B, C, 0);

  mzd_t *T0 = mzd_add(NULL, A, B);
  mzd_t *R1 = mzd_mul(NULL, T0, C, 0);

  int r = mzd_equal(R0, R1);

  FILE *fh = tmpfile();
  mzd_to_png_fh(A, fh, 1, NULL, 0);
  fflush(fh);
  fseek(fh, 0, SEEK_SET);
  mzd_t *AA = mzd_from_png_fh(fh, 0);
  fclose(fh);
  r &= mzd_equal(A, AA);

  mzd_free(AA);
  mzd_free(T0);
  mzd_free(R1);
  mzd_free(R0);

  mzd_free(C);
  mzd_free(B);
  mzd_free(A);

  if (r == TRUE) {
    fprintf(stderr, "M4RI test passed.");
    return 0;
  } else {
    fprintf(stderr, "M4RI test failed.");
    return -1;
  }
}
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lm4ri", "-o", "test"
    system "./test"
  end
end

__END__


diff --git a/ltmain.sh b/ltmain.sh
index 977e523..3f3bc31 100755
--- a/ltmain.sh
+++ b/ltmain.sh
@@ -6856,6 +6856,16 @@ func_mode_link ()
     # See if our shared archives depend on static archives.
     test -n "$old_archive_from_new_cmds" && build_old_libs=yes
 
+    # make sure "-Xpreprocessor -fopenmp" is processed as one token
+    case "$@" in
+    *-Xpreprocessor\ -fopenmp*)
+      fopenmp_match="-Xpreprocessor -fopenmp"
+      ;;
+    *)
+      fopenmp_match="-fopenmp"
+      ;;
+    esac
+
     # Go through the arguments, transforming them on the way.
     while test "$#" -gt 0; do
       arg=$1
@@ -7339,7 +7349,7 @@ func_mode_link ()
 	continue
 	;;
       -mt|-mthreads|-kthread|-Kthread|-pthreads|--thread-safe \
-      |-threads|-fopenmp|-openmp|-mp|-xopenmp|-omp|-qsmp=*)
+      |-threads|$fopenmp_match|fopenmp=*|-openmp|-mp|-xopenmp|-omp|-qsmp=*)
 	func_append compiler_flags " $arg"
 	func_append compile_command " $arg"
 	func_append finalize_command " $arg"
@@ -7888,7 +7898,7 @@ func_mode_link ()
 	found=false
 	case $deplib in
 	-mt|-mthreads|-kthread|-Kthread|-pthread|-pthreads|--thread-safe \
-        |-threads|-fopenmp|-openmp|-mp|-xopenmp|-omp|-qsmp=*)
+        |-threads|$fopenmp_match|fopenmp=*|-openmp|-mp|-xopenmp|-omp|-qsmp=*)
 	  if test prog,link = "$linkmode,$pass"; then
 	    compile_deplibs="$deplib $compile_deplibs"
 	    finalize_deplibs="$deplib $finalize_deplibs"
