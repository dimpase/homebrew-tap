class Libhomfly < Formula
  desc "Compute the homfly polynomial of knots and links"
  homepage "https://github.com/miguelmarco/libhomfly"
  url "https://github.com/miguelmarco/libhomfly/releases/download/1.04/libhomfly-1.04.tar.gz"
  sha256 "659a77b4f4b53340d24a7d6a69f4219e77ab9439a6ab8afa0156b7f6bd7af64f"
  license :public_domain

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/libhomfly-1.04"
    sha256 cellar: :any,                 arm64_tahoe:  "5b7cfc49e9afe3aec917afbe8ea6e04a4f7f04c9c4c5dc8e13b175df9d5c5515"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f2c9fcd14bdd28baa7de2f0a0f0352ef963717aed7a0a8b8a3199898c3193038"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "bdw-gc"
  depends_on "pkgconf"

  def install
    system "autoreconf", "-ivf"
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
