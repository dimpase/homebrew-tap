class Libbraiding < Formula
  desc "Computing with braids"
  homepage "https://github.com/miguelmarco/libbraiding"
  url "https://github.com/miguelmarco/libbraiding/releases/download/1.3.2/libbraiding-1.3.2.tar.gz"
  sha256 "d43a32e7770d5c9a89ae489c5ac353da9610a761f76745382cf7612eab046ffd"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/libbraiding-1.3.2"
    sha256 cellar: :any,                 arm64_tahoe:  "f4cf402e6c3265ec811aa69257b94b5bd564abfa0b42e94bba77664edca8c74e"
    sha256 cellar: :any,                 sequoia:      "5de11848b89141cd2d64f715da095b00e7fedf735d2adefe4c9d2527cdcb0730"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "da900cf54554e15c85083805819841e5f2912e7f67bda725636d53f9282ab912"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
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
