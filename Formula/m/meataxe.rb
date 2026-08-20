class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.2/shared_meataxe-1.0.2.tar.bz2"
  sha256 "c2e2ec85cdbcde5800d7b0577937afcc86f4a7610ae4d86614428445deb301e8"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/meataxe-1.0.2"
    sha256 cellar: :any,                 arm64_tahoe:  "482f0c606a4547e34fdedac352326c3a12596bfbdf5ecbe92c9846acb25db69a"
    sha256 cellar: :any,                 sequoia:      "43a03d954d359cdd99b363bcc61c21e4d7f323106bc1cacaf30b0b0d69b3886d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c304b177a8ec83ab0336800edc31dd0e9df0228eae46631faaacbd34912a2f0f"
  end

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
