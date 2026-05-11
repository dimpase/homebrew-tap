class Sirocco < Formula
  desc "Topologically certified root continuation of bivariate polynomials"
  homepage "https://github.com/miguelmarco/SIROCCO2"
  url "https://github.com/miguelmarco/SIROCCO2/releases/download/2.1.1/libsirocco-2.1.1.tar.gz"
  sha256 "83d1dd5622120eda42c475696235dd67be8072a76baad0a70693d9743a659a61"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/sirocco-2.1.1"
    sha256 cellar: :any,                 arm64_tahoe:  "045940e1eeaa52fe2e44972b0bc61728484357cf8d550832edf14b4e545c5f9b"
    sha256 cellar: :any,                 sequoia:      "df4c8884b0d8fc43c095761311b2e917e9cc5eb9efe5f1f1a6182b0a0c0c40a4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1177482b43470df1f1c0e3c28f06ee7459178565a57681e2836652ebaf065408"
  end

  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "pkgconf"

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system "true"
  end
end
