class MaximaEcl < Formula
  desc "Computer algebra system - compiled with ecl"
  homepage "https://maxima.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/maxima/Maxima-source/5.49.0-source/maxima-5.49.0.tar.gz"
  sha256 "6d401a4aa307cd3a5a9cadca4fa96c4ef0e24ff95a18bb6a8f803e3d2114adee"
  license "GPL-2.0-only"
  revision 2

  livecheck do
    url :stable
    regex(%r{url=.*?/maxima[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/maxima-ecl-5.49.0_2"
    sha256 cellar: :any, arm64_tahoe:  "9d2fa41ccfa1bbed342322c36c97dccc98cd5ddfae48b8b42b500f279f1df815"
    sha256 cellar: :any, arm64_linux:  "104f1d97e7f49f789c36865c1ca24987f700b6959e5a9db25c0bc97d4c98f4e5"
    sha256 cellar: :any, x86_64_linux: "cadcb7d03bc70450c04268b121318fe48a8ce27a0042b1d7c94ffa3760bafc28"
  end

  depends_on "gawk" => :build
  depends_on "texinfo" => :build
  depends_on "bdw-gc"
  depends_on "ecl"
  depends_on "gettext"
  depends_on "gmp"
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
                          "--with-ecl=#{formula_opt_bin("ecl")}/ecl",
                          *std_configure_args
    system "make"
    require "fileutils"
    ohai "Now installing the Maxima library maxima.fas into #{lib}/ecl-#{Formula["ecl"].version}"
    chmod 0444, "src/binary-ecl/maxima.fas", verbose: true
    (lib/"ecl-#{Formula["ecl"].version}").install "src/binary-ecl/maxima.fas"
    ohai "Now installing the rest of Maxima..."
    system "make", "install"
  end

  def caveats
    <<~EOS
      To use Maxima's Gnuplot plotting backend, install Gnuplot separately:
        brew install gnuplot

      SageMath's Matplotlib-based plotting does not require Gnuplot.
    EOS
  end

  test do
    system bin/"maxima", "--batch-string=run_testsuite(); quit();"
  end
end
