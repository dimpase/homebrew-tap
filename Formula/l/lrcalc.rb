class Lrcalc < Formula
  desc "Littlewood-Richardson Calculator"
  homepage "https://sites.math.rutgers.edu/~asbuch/lrcalc"
  url "https://sites.math.rutgers.edu/~asbuch/lrcalc/lrcalc-2.1.tar.gz"
  sha256 "996ac00e6ea8321ef09b34478f5379f613933c3254aeba624b6419b8afa5df57"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/lrcalc-2.1"
    sha256 cellar: :any, arm64_tahoe:  "1c7dcf915951938ace614325551c943a627bed4d1b97bdc65bccffe552b44b26"
    sha256 cellar: :any, sequoia:      "7378fcea994276234eb24cf6f9d45d35a3d2b8c48905954744792b22281e5db1"
    sha256 cellar: :any, x86_64_linux: "b8b5bfe66cc279163b4e7f44e7d70a70b4d3c17bd5fe9f8e6e83a43cb1ec0353"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--prefix=#{prefix}", "--disable-static"
    system "make"
    system "make", "install"
  end

  test do
    assert_match "1  (5,4,3)", shell_output("#{bin}/lrcalc  mult -f 3,2 3 2 1 - 3 2 1 | grep '(5,4,3)$'")
  end
end
