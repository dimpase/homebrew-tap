class Lrcalc < Formula
  desc "Littlewood-Richardson Calculator"
  homepage "https://sites.math.rutgers.edu/~asbuch/lrcalc"
  url "https://sites.math.rutgers.edu/~asbuch/lrcalc/lrcalc-2.1.tar.gz"
  sha256 "996ac00e6ea8321ef09b34478f5379f613933c3254aeba624b6419b8afa5df57"
  license "GPL-2.0-or-later"

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
