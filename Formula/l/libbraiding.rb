class Libbraiding < Formula
  desc "Computing with braids"
  homepage "https://github.com/miguelmarco/libbraiding"
  url "https://github.com/miguelmarco/libbraiding/releases/download/1.3.2/libbraiding-1.3.2.tar.gz"
  sha256 "d43a32e7770d5c9a89ae489c5ac353da9610a761f76745382cf7612eab046ffd"
  license "GPL-3.0-or-later"

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
