class Sirocco < Formula
  desc "Topologically certified root continuation of bivariate polynomials"
  homepage "https://github.com/miguelmarco/SIROCCO2"
  url "https://github.com/miguelmarco/SIROCCO2/releases/download/2.1.1/libsirocco-2.1.1.tar.gz"
  sha256 "83d1dd5622120eda42c475696235dd67be8072a76baad0a70693d9743a659a61"
  license "GPL-3.0-or-later"

  depends_on "libtool" => :build
  depends_on "mpfr"

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
