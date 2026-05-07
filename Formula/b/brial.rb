class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]

  depends_on "libtool" => :build
  depends_on "boost"
  depends_on "libomp" if OS.mac?
  depends_on "libpng"
  depends_on "m4ri"

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--with-boost=#{HOMEBREW_PREFIX}", "--with-boost-libdir=#{HOMEBREW_PREFIX}/lib",
      "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "true"
  end
end
