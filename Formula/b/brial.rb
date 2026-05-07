class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/brial-1.2.15"
    sha256 cellar: :any,                 arm64_tahoe:  "d3d5077de6a11d77b4086298e6a0bfc361b3cf9d30558c9ce81d02df629e130e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0f22026588733d540b327807eae6cfc423d7fe1dfaa7e8e3591f5a7c112bb20a"
  end

  depends_on "libtool" => :build
  depends_on "boost"
  depends_on "libomp" if OS.mac?
  depends_on "libpng"
  depends_on "m4ri"
  depends_on "pkgconf"

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
