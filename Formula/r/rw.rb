class Rw < Formula
  desc "Program to calculate rank-width and rank-decompositions"
  homepage "https://sourceforge.net/projects/rankwidth"
  url "https://downloads.sourceforge.net/project/rankwidth/rw-0.10.tar.gz"
  sha256 "89a8ed364893ac1b70ab70a152e3e7db3cf348bb69098aa6dbb969639df927db"
  license "GPL-2.0-or-later"

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
