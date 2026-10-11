class Pari < Formula
  desc "Computer algebra system designed for fast computations in number theory"
  homepage "https://pari.math.u-bordeaux.fr/"
  url "https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-2.19.0.tar.gz"
  sha256 "f317b9722eb5d9094a60303774f066f3a83e3ec1f170be8546c44d7583f30b6d"
  license "GPL-2.0-or-later"
  revision 2
  compatibility_version 1

  livecheck do
    url "https://pari.math.u-bordeaux.fr/pub/pari/unix/"
    regex(/href=.*?pari[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-2.19.0_2"
    sha256 arm64_tahoe:  "eda9e73963d7664706226c0860b008289a9bb497495a79a4a834129865d07bb2"
    sha256 arm64_linux:  "e0b19939d91b9822ca68e1766a4bd2b1eeec547ac719026d56d9f50b4398f7ed"
    sha256 x86_64_linux: "329edf9b352c921dd1183489a59b792a2063cd40367533bcf40533835ce07b15"
  end

  depends_on "gmp"
  depends_on "readline"

  # Backport upstream fixes for hyperellcharpoly and empty parallel coefficient vectors.
  # https://pari.math.u-bordeaux.fr/cgi-bin/bugreport.cgi?bug=2703
  # Upstream: 603d02feac84d67c92688cbd60e366ee19776492
  # https://pari.math.u-bordeaux.fr/cgi-bin/bugreport.cgi?bug=2704
  # Upstream: 6fcdb19f551b5695a13c2ea8ec05796629dcc546
  # Reject numerically noninvertible complex Gaussian pivots (candidate upstream fix).
  # https://pari.math.u-bordeaux.fr/cgi-bin/bugreport.cgi?bug=2708
  # Prevent Darwin worker exceptions from blocking signals in every thread.
  patch :DATA

  def install
    # Work around for optimization bug causing corrupted last_tmp_file
    # Ref: https://github.com/Homebrew/homebrew-core/issues/207722
    # Ref: https://pari.math.u-bordeaux.fr/cgi-bin/bugreport.cgi?bug=2608
    ENV.O1 if ENV.compiler == :clang

    readline = formula_opt_prefix("readline")
    gmp = formula_opt_prefix("gmp")
    system "./Configure", "--prefix=#{prefix}",
                          "--with-gmp=#{gmp}",
                          "--with-readline=#{readline}",
                          "--graphic=ps",
                          "--mt=pthread"

    # Explicitly set datadir to HOMEBREW_PREFIX/share/pari to allow for external packages to be found
    # We do this here rather than in configure because we still want the actual files to be installed to the Cellar
    objdir = Utils.safe_popen_read("./config/objdir").chomp
    inreplace %W[#{objdir}/pari.cfg #{objdir}/paricfg.h], pkgshare, "#{HOMEBREW_PREFIX}/share/pari"

    # make needs to be done in two steps
    system "make", "all"
    system "make", "install"

    # Avoid references to Homebrew shims
    inreplace lib/"pari/pari.cfg", Superenv.shims_path, "/usr/bin"
  end

  def caveats
    <<~EOS
      If you need the graphical plotting functions you need to install X11 with:
        brew install --cask xquartz
    EOS
  end

  test do
    (testpath/"math.tex").write "$k_{n+1} = n^2 + k_n^2 - k_{n-1}$"
    system bin/"tex2mail", testpath/"math.tex"

    (testpath/"test.gp").write <<~GP
      default(parisize,"1G");
      default(realprecision,10);
      default(nbthreads,4);
      dist(a,b) = sqrt(a^2+b^2);
      print(dist(1,2));
      check(b) = {
        localbitprec(b);
        my(m = [0,1;-2,0], e = mateigen(m,1));
        if(norml2(m*e[2]-e[2]*matdiagonal(e[1])) > 2.^(-b/2), error("eigenvector residual"));
      };
      check_pivot() = {
        localbitprec(53);
        my(r = polroots(x^2+2)[1], a = [-r,1;-2,-r]);
        if(matrank(a) != 1, error("rank"));
        if(matsize(matker(a)) != [2,1], error("kernel"));
        if(matsize(matimage(a)) != [2,1], error("image"));
        if(#matindexrank(a)[1] != 1, error("index rank"));
      };
      iferr(for(b=15,193,check(b)); check_pivot(), E, print(E); quit(1));
      print("complex pivot regression passed");
      check_regressions() = {
        my(z = ffgen(23^3, 'z), p = hyperellcharpoly(t^3 + z*t + 4));
        if(p != x^2 - 11*x + 12167, error("hyperellcharpoly regression"));
        my(e = ellinit([0,0,0,1,2]));
        if(abs(lfun(e,1000) - 1) > 1e-8, error("lfun large argument regression"));
        localbitprec(53);
        if(exponent(lfun(e,100) - 1) >= -52, error("lfun empty vector regression"));
      };
      iferr(check_regressions(), E, print(E); quit(1));
      print("hyperellcharpoly and lfun regressions passed");
      check_parallel_alarms() = {
        parsum(i=1,4,iferr(1/0,E,0));
        for(i=1,2,
          if(type(alarm(1,for(k=1,10^8,isprime(k)))) != "t_ERROR", error("parallel alarm regression"))
        );
      };
      iferr(check_parallel_alarms(), E, print(E); quit(1));
      print("parallel alarm regression passed");
    GP
    expected = <<~EOS
      2.236067977
      complex pivot regression passed
      hyperellcharpoly and lfun regressions passed
      parallel alarm regression passed
    EOS
    assert_equal expected, pipe_output("#{bin}/gp --quiet test.gp", "", 0)
  end
end

__END__
diff --git a/src/basemath/alglin1.c b/src/basemath/alglin1.c
index f1ff13c7b0..9bddfaef65 100644
--- a/src/basemath/alglin1.c
+++ b/src/basemath/alglin1.c
@@ -2300,7 +2300,8 @@ gauss_get_pivot_max(GEN X, GEN X0, long ix, GEN c)
   if (!k) return lx;
   p = gel(x,k);
   r = gel(x0,k); if (isrationalzero(r)) r = x0;
-  return cx_approx0(p, r)? lx: k;
+  return (cx_approx0(p, r)
+          || (typ(p) == t_COMPLEX && gequal0(cxnorm(p))))? lx: k;
 }
 static long
 gauss_get_pivot_padic(GEN X, GEN p, long ix, GEN c)

diff --git a/src/basemath/ZX.c b/src/basemath/ZX.c
index c40c8b3cea..2899e195fa 100644
--- a/src/basemath/ZX.c
+++ b/src/basemath/ZX.c
@@ -1284,7 +1284,7 @@ RgXX_to_Kronecker_var(GEN P0, long n, long vx)
   {
     long j;
     GEN c = gel(P,i);
-    if (typ(c) != t_POL || varn(c) != vx)
+    if (typ(c) != t_POL || varncmp(varn(c), vx) > 0)
     {
       gel(y,k++) = c;
       j = 3;

diff --git a/src/basemath/alglin3.c b/src/basemath/alglin3.c
index a7ab2fec84..69a47fa428 100644
--- a/src/basemath/alglin3.c
+++ b/src/basemath/alglin3.c
@@ -845,9 +845,13 @@ arithprogset(GEN B, GEN A, long r, long m)
 GEN
 gen_parapply_slice(GEN worker, GEN D, long mmin)
 {
-  long l, r, n = lg(D)-1, m = minss(mmin, n), pending = 0;
-  GEN L = cgetg(n / m + 2, t_VEC), va = mkvec(L), V = cgetg_copy(D, &l);
+  long l, r, n, m, pending = 0;
+  GEN L, va, V = cgetg_copy(D, &l);
   struct pari_mt pt;
+
+  n = l-1; if (!n) return V;
+  m = minss(mmin, n);
+  L = cgetg(n / m + 2, t_VEC); va = mkvec(L);
   mt_queue_start_lim(&pt, worker, m);
   for (r = 1; r <= m || pending; r++)
   {
@@ -868,12 +872,15 @@ gen_parapply_slice(GEN worker, GEN D, long mmin)
 GEN
 gen_parapply_slice_zv(GEN worker, GEN D, long mmin)
 {
-  long l, r, n = lg(D)-1, m = minss(mmin, n), pending = 0;
+  long l, r, n, m, pending = 0;
   struct pari_mt pt;
-  GEN L, va, V;
+  GEN L, va, V = cgetg_copy(D, &l);
+
+  n = l-1; if (!n) return V;
+  m = minss(mmin, n);
   if (m == 1) return closure_callgen1(worker, D);
   L = cgetg(n / m + 2, t_VECSMALL);
-  va = mkvec(L); V = cgetg_copy(D, &l);
+  va = mkvec(L);
   mt_queue_start_lim(&pt, worker, m);
   for (r = 1; r <= m || pending; r++)
   {
@@ -894,13 +901,12 @@ gen_parapply_slice_zv(GEN worker, GEN D, long mmin)
 GEN
 gen_parapply_percent(GEN worker, GEN D, long percent)
 {
-  long l = lg(D), i, pending = 0, cnt = 0, lper = -1, lcnt = 0;
+  long l, i, pending = 0, cnt = 0, lper = -1, lcnt = 0;
   long W[] = {evaltyp(t_VEC) | _evallg(2), 0};
-  GEN V;
+  GEN V = cgetg_copy(D, &l);
   struct pari_mt pt;

-  if (l == 1) return cgetg(1, typ(D));
-  V = cgetg(l, typ(D));
+  if (l == 1) return V;
   mt_queue_start_lim(&pt, worker, l-1);
   for (i = 1; i < l || pending; i++)
   {

diff --git a/src/headers/parisys.h b/src/headers/parisys.h
--- a/src/headers/parisys.h
+++ b/src/headers/parisys.h
@@ -50,6 +50,18 @@
 #  define THREAD
 #endif

+/* Darwin longjmp restores signal masks with sigprocmask, which changes the
+ * masks of all threads. A caught error in a signal-blocked worker must not
+ * block signals in the main thread. Keep jmp_buf and use the mask-free pair.
+ * Other platforms retain their existing error-recovery behavior. */
+#ifdef __APPLE__
+#  define pari_setjmp(env) _setjmp(env)
+#  define pari_longjmp(env, val) _longjmp(env, val)
+#else
+#  define pari_setjmp(env) setjmp(env)
+#  define pari_longjmp(env, val) longjmp(env, val)
+#endif
+
 #if defined(_WIN32) || defined(__CYGWIN32__)
 /* ANSI C does not allow to longjmp() out of a signal handler, in particular,
  * the SIGINT handler. On Win32, the handler is executed in another thread, and
diff --git a/src/headers/paricom.h b/src/headers/paricom.h
--- a/src/headers/paricom.h
+++ b/src/headers/paricom.h
@@ -46,7 +46,7 @@
   jmp_buf *var=iferr_env;    \
   jmp_buf __env;             \
   iferr_env = &__env;        \
-  if (setjmp(*iferr_env))    \
+  if (pari_setjmp(*iferr_env))    \
   {                          \
     GEN __iferr_data = pari_err_last(); \
     iferr_env = var; \
diff --git a/src/gp/gp.c b/src/gp/gp.c
--- a/src/gp/gp.c
+++ b/src/gp/gp.c
@@ -50,7 +50,7 @@
 static void
 gp_err_recover(long numerr)
 {
-  longjmp(env[s_env.n-1], numerr);
+  pari_longjmp(env[s_env.n-1], numerr);
 }

 /* numerr >= 0 */
@@ -298,7 +298,7 @@
   Buffer *b = filtered_buffer(&F);
   struct gp_context rec;
   long er;
-  if ((er = setjmp(env[s_env.n-1])))
+  if ((er = pari_setjmp(env[s_env.n-1])))
   { /* recover: jump from error [ > 0 ] or allocatemem [ -1 ] */
     if (er > 0) { /* true error */
       if (!(GP_DATA->recover)) exit(1);
@@ -370,7 +370,7 @@
 read_main(const char *s)
 {
   GEN z;
-  if (setjmp(env[s_env.n-1]))
+  if (pari_setjmp(env[s_env.n-1]))
     z = NULL;
   else {
     FILE *f = switchin(s);
@@ -429,13 +429,13 @@
     long er, br_status;
     set_avma(av);
     gp_context_save(&rec2);
-    if ((er=setjmp(env[nenv])))
+    if ((er=pari_setjmp(env[nenv])))
     {
       if (er < 0)
       {
         s_env.n = 1;
         frame_level = oldframe_level;
-        longjmp(env[s_env.n-1], er);
+        pari_longjmp(env[s_env.n-1], er);
       }
       gp_context_restore(&rec2);
       iferr_env = NULL;
@@ -521,7 +521,7 @@
   pari_stack_init(&s_env, sizeof(*env), (void**)&env);
   (void)pari_stack_new(&s_env);

-  if (setjmp(env[s_env.n-1]))
+  if (pari_setjmp(env[s_env.n-1]))
   {
     puts("### Errors on startup, exiting...\n\n");
     exit(1);
diff --git a/src/language/init.c b/src/language/init.c
--- a/src/language/init.c
+++ b/src/language/init.c
@@ -1884,7 +1884,7 @@
     numerr = err_get_num(E);
   }
   global_err_data = E;
-  if (*iferr_env) longjmp(*iferr_env, numerr);
+  if (*iferr_env) pari_longjmp(*iferr_env, numerr);
   mt_err_recover(numerr);
   va_end(ap);
   if (cb_pari_err_handle &&
diff --git a/src/language/gplib.c b/src/language/gplib.c
--- a/src/language/gplib.c
+++ b/src/language/gplib.c
@@ -1032,7 +1032,7 @@
   for(;;)
   {
     char *nexts, *s, *t;
-    if (setjmp(env[s_env.n-1])) err_printf("...skipping line %ld.\n", c);
+    if (pari_setjmp(env[s_env.n-1])) err_printf("...skipping line %ld.\n", c);
     c = c + 1;
     if (!get_line_from_file(NULL,&F,file)) break;
     s = b->buf;
diff --git a/src/mt/mpi.c b/src/mt/mpi.c
--- a/src/mt/mpi.c
+++ b/src/mt/mpi.c
@@ -242,7 +242,7 @@
   struct gp_context rec;
   pari_mt_nbthreads = 1;
   gp_context_save(&rec);
-  if (setjmp(child_env))
+  if (pari_setjmp(child_env))
   {
     send_GEN(pari_err_last(), 0);
     gp_context_restore(&rec);
@@ -322,7 +322,7 @@
 void
 mt_err_recover(long er)
 {
-  if (pari_MPI_rank) longjmp(child_env,er);
+  if (pari_MPI_rank) pari_longjmp(child_env,er);
   else mtsingle_err_recover(er);
 }

diff --git a/src/test/in/parallel b/src/test/in/parallel
--- a/src/test/in/parallel
+++ b/src/test/in/parallel
@@ -52,6 +52,9 @@

 my(N=1);until(type(A)=="t_ERROR",A=alarm(1,parfor(i=1,10,for(i=1,N,isprime(i))));N*=2);

+/* A caught worker error must leave the main thread able to receive alarms. */
+parsum(i=1,4,iferr(1/0,E,0)); type(alarm(1,while(1,)))
+
 my(s,L=List());parfor(x=1,10,x!,f,s+=f);s
 my(s,L=List());parfor(x=1,oo,if(x<=10,x!),f,s+=f;if(x>=10,break));s
 my(s);parforprime(p=2,20,p!,f,s+=f);s
diff --git a/src/test/32/parallel b/src/test/32/parallel
--- a/src/test/32/parallel
+++ b/src/test/32/parallel
@@ -52,6 +52,7 @@
 7432339208719
 7432339208719
 [75, 85070591730234615858594180193637120807]
+"t_ERROR"
 4037913
 4037913
 122000794103870768
