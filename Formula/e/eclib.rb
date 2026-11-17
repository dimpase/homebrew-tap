class Eclib < Formula
  desc "Enumerating and computing with elliptic curves over Q"
  homepage "https://johncremona.github.io/mwrank/index.html"
  url "https://github.com/JohnCremona/eclib/releases/download/20250627/eclib-20250627.tar.bz2"
  sha256 "b88d4b52612e491c5415946d9e35f2062ca1015ee7fbbe0b61f158fa74cb4bc9"
  license "GPL-2.0-or-later"
  revision 3

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/eclib-20250627_3"
    sha256 cellar: :any, arm64_tahoe:  "e0412e7d7fdcd528aa7d66a96a084881279ca3bd3647377b23612b0ba3c0c0d6"
    sha256 cellar: :any, arm64_linux:  "0cf1fd6690e881e55fdacb12bdf77b41c33e6b4cf3f3037134b8193d71c11595"
    sha256 cellar: :any, x86_64_linux: "b869eade8eea4435806b4aa7d24d015bed0111e00898cbc5b74230446c433204"
  end

  depends_on "libtool" => :build
  depends_on "flint"
  depends_on "gf2x"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "ntl"
  depends_on "pari"
  depends_on "pkgconf"

  def install
    system "./configure", "--with-ntl", "--with-pari", "--with-flint",
      "--with-boost=no", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system "true"
  end
end
