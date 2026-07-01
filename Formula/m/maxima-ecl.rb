class MaximaEcl < Formula
  desc "Computer algebra system - compiled with ecl"
  homepage "https://maxima.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/maxima/Maxima-source/5.49.0-source/maxima-5.49.0.tar.gz"
  sha256 "6d401a4aa307cd3a5a9cadca4fa96c4ef0e24ff95a18bb6a8f803e3d2114adee"
  license "GPL-2.0-only"
  revision 1

  livecheck do
    url :stable
    regex(%r{url=.*?/maxima[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/maxima-ecl-5.49.0_1"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "064f468355b4b6354294047e9bc3b804b24f1fcf72c0ca26d370eaff6da4a42f"
    sha256 cellar: :any, x86_64_linux: "36e6680f07deed8a4bdd1e40adc31d65204ece0e6bf1544c5c252955c14857c6"
  end

  depends_on "gawk" => :build
  depends_on "texinfo" => :build
  depends_on "bdw-gc"
  depends_on "ecl"
  depends_on "gettext"
  depends_on "gmp"
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

  test do
    system bin/"maxima", "--batch-string=run_testsuite(); quit();"
  end
end
