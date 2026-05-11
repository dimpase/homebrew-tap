class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.2/shared_meataxe-1.0.2.tar.bz2"
  sha256 "c2e2ec85cdbcde5800d7b0577937afcc86f4a7610ae4d86614428445deb301e8"
  license "GPL-2.0-or-later"

  depends_on "libtool" => :build

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
