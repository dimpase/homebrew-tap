class Rw < Formula
  desc "Program to calculate rank-width and rank-decompositions"
  homepage "https://sourceforge.net/projects/rankwidth"
  url "https://downloads.sourceforge.net/project/rankwidth/rw-0.10.tar.gz"
  sha256 "89a8ed364893ac1b70ab70a152e3e7db3cf348bb69098aa6dbb969639df927db"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/rw-0.10"
    sha256 cellar: :any,                 arm64_tahoe:  "51925dcc2373fbfebc68b916ed522a814cb32c70c022c3cc805a4a789125b886"
    sha256 cellar: :any,                 sequoia:      "f2eb17bafcdfb9414c3ac6f26ab5893dbdc4642d45e50c1275a3c437fff9c385"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9f4a593f9fa1e90ebbd725c531c5278684837faca1394ddeeda29b38d3b2a028"
  end

  depends_on "libtool" => :build

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--disable-executable", "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "true"
  end
end
