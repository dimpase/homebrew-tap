class Eclib < Formula
  desc "Enumerating and computing with elliptic curves over Q"
  homepage "https://johncremona.github.io/mwrank/index.html"
  url "https://github.com/JohnCremona/eclib/releases/download/20250627/eclib-20250627.tar.bz2"
  sha256 "b88d4b52612e491c5415946d9e35f2062ca1015ee7fbbe0b61f158fa74cb4bc9"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/eclib-20250627_1"
    sha256 cellar: :any, arm64_tahoe:  "d6bd75b5d81882eff5bf855b4c621a6173c2685c762aa5eb8ef54011785adc31"
    sha256 cellar: :any, x86_64_linux: "419b11f1cbac9f5e436e49ff81e0d95271c68877e431160e50981694ea3fb99d"
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
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--with-ntl", "--with-pari", "--with-flint",
      "--with-boost=no", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system "true"
  end
end
