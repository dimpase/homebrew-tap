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

  depends_on "gmp"
  depends_on "readline"

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
    GP
    assert_equal "2.236067977\ncomplex pivot regression passed\n", pipe_output("#{bin}/gp --quiet test.gp", "", 0)
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
