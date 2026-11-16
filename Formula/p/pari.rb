class Pari < Formula
  desc "Computer algebra system designed for fast computations in number theory"
  homepage "https://pari.math.u-bordeaux.fr/"
  url "https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-2.19.1.tar.gz"
  sha256 "419553b11ff8c3ecb8e9031b7d91d7cee003a5d721e685fcb499565c96fe2943"
  license "GPL-2.0-or-later"
  compatibility_version 2

  livecheck do
    url "https://pari.math.u-bordeaux.fr/pub/pari/unix/"
    regex(/href=.*?pari[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "gmp"
  depends_on "readline"

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
    assert_equal expected, pipe_output("#{bin}/gp --quiet -s 1G test.gp", "", 0)
  end
end
