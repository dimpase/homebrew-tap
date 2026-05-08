class MaximaEcl < Formula
  desc "Computer algebra system - compiled with ecl"
  homepage "https://maxima.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/maxima/Maxima-source/5.49.0-source/maxima-5.49.0.tar.gz"
  sha256 "6d401a4aa307cd3a5a9cadca4fa96c4ef0e24ff95a18bb6a8f803e3d2114adee"
  license "GPL-2.0-only"
  revision 5

  livecheck do
    url :stable
    regex(%r{url=.*?/maxima[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  depends_on "gawk" => :build
  depends_on "texinfo" => :build
  depends_on "ecl"
  depends_on "gettext"
  depends_on "gnuplot"
  depends_on "rlwrap"

  uses_from_macos "perl" => :build

  on_macos do
    depends_on "gnu-sed" => :build
  end

  conflicts_with "maxima", because: "sbcl maxima is installed by default"

  def install
    ENV["LANG"] = "C" # per build instructions
    system "./configure", "--enable-gettext",
                          "--enable-ecl",
                          "--with-emacs-prefix=#{elisp}",
                          "--with-ecl=#{Formula["ecl"].opt_bin}/ecl",
                          *std_configure_args
    system "make"
    require "fileutils"
    faspath = `ecl -eval "(princ (SI:GET-LIBRARY-PATHNAME))" -eval "(quit)"`
    ohai "Now installing the Maxima library maxima.fas into #{faspath}"
    chmod 0444, "src/binary-ecl/maxima.fas", verbose: true
    cp "src/binary-ecl/maxima.fas", faspath
    ohai "Now installing the rest of Maxima..."
    system "make", "install"
  end

  test do
    system bin/"maxima", "--batch-string=run_testsuite(); quit();"
  end
end
