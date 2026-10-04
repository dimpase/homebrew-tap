class Pari < Formula
  desc "Computer algebra system designed for fast computations in number theory"
  homepage "https://pari.math.u-bordeaux.fr/"
  url "https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-2.19.0.tar.gz"
  sha256 "f317b9722eb5d9094a60303774f066f3a83e3ec1f170be8546c44d7583f30b6d"
  license "GPL-2.0-or-later"
  revision 1
  compatibility_version 1

  livecheck do
    url "https://pari.math.u-bordeaux.fr/pub/pari/unix/"
    regex(/href=.*?pari[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-2.19.0_1"
    sha256 arm64_tahoe:  "6eb74783700c645f5485e4fa9f70be5beb6527eb340cef40b9efa4504be1dd4d"
    sha256 arm64_linux:  "dd5f64b32571060e76c15cae2999e3fba5f8d8353f85b8ff8ec4c4a767603891"
    sha256 x86_64_linux: "fad0fb5fc0630c2787ff6c2d0a4259eccd70312335b2b0ad7fad87d5c816fd69"
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
    GP
    expected = "2.236067977\ncomplex pivot regression passed\nhyperellcharpoly and lfun regressions passed\n"
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
