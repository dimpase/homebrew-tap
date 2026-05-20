class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/brial-1.2.15"
    rebuild 2
    sha256 cellar: :any,                 arm64_tahoe:  "d5ddd54a47a870684589386d4730ae87a3a91950d43aeeb1f2c1e9790a052e38"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "12a54560e697dc73ccad7d4c366d74b7126eb13b2bf5bf8c86a188df93b4aa65"
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
