class Brial < Formula
  desc "Boolean Ring Algebra package, formerly PolyBoRi"
  homepage "https://github.com/BRiAl/BRiAl"
  url "https://github.com/BRiAl/BRiAl/releases/download/1.2.15/brial-1.2.15.tar.bz2"
  sha256 "1d0e7de01b1b60ad892dee6c02503f5932e2ed211f3f8dbdf1a3216c696ef201"
  license all_of: ["0BSD", "GPL-2.0-only"]

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/brial-1.2.15"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:  "a5c2ad79357b3578c29b8f36e484182826153caeac496d77951726c3fd56b9c9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dabe998c8ea1125b1c1d85c4a575e0ce2b7cd81408f0f80d06f7c70ee586d8e1"
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
      "--disable-static", "--disable-silent-rules", *std_configure_args, "--disable-debug"
    system "make", "install"
  end

  test do
    system "true"
  end
end
