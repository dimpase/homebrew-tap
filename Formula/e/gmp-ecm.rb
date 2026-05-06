class GmpEcm < Formula
  desc "Elliptic Curve Method for Integer Factorization"
  homepage "https://gitlab.inria.fr/zimmerma/ecm"
  url "https://gitlab.inria.fr/-/project/24244/uploads/ad3e5019fef98819ceae58b78f4cce93/ecm-7.0.6.tar.gz"
  sha256 "7d20ece61ab6a20ad85f2c18064cabd77dc46a96ff894b5220dbb16e4666e8a5"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/gmp-ecm-7.0.6"
    sha256 cellar: :any,                 arm64_tahoe:  "25e26bf4e8cbf156d28c244f5a3d5d2a99d2a93de01c6d9817ec0268210c3f19"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "eb88e1950a245b0d86d017d569d203caf79d930793843a4f5edcf14128723442"
  end

  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "libomp" if OS.mac?

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--enable-openmp", "--enable-shared", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "true"
  end
end
