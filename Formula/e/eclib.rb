class Eclib < Formula
  desc "Enumerating and computing with elliptic curves over Q"
  homepage "https://johncremona.github.io/mwrank/index.html"
  url "https://github.com/JohnCremona/eclib/releases/download/20250627/eclib-20250627.tar.bz2"
  sha256 "b88d4b52612e491c5415946d9e35f2062ca1015ee7fbbe0b61f158fa74cb4bc9"
  license "GPL-2.0-or-later"
  revision 2

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/eclib-20250627_2"
    sha256 cellar: :any, arm64_tahoe:  "d50062f5adbb195bb6a97a0eca135b561a12a035bf6b332b087c69254ac7134e"
    sha256 cellar: :any, arm64_linux:  "ce90abf8ac372ac0436b06cd6980b7c55e1f2cbd122c4f318b0352749b314163"
    sha256 cellar: :any, x86_64_linux: "d6be0872d39c19f3a43186daa0dd75c36ab0c20fd3a7970b87a93391ce2dbb93"
  end

  depends_on "libtool" => :build
  depends_on "dimpase/tap/pari"
  depends_on "flint"
  depends_on "gf2x"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "ntl"
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
