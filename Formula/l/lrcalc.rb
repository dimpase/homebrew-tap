class Lrcalc < Formula
  desc "Littlewood-Richardson Calculator"
  homepage "https://sites.math.rutgers.edu/~asbuch/lrcalc"
  url "https://sites.math.rutgers.edu/~asbuch/lrcalc/lrcalc-2.1.tar.gz"
  sha256 "996ac00e6ea8321ef09b34478f5379f613933c3254aeba624b6419b8afa5df57"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/lrcalc-2.1"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "2e8ff20de6c05e4394d8ef7a69241cc1d195d7a61c862e080aecd919edd23d84"
    sha256 cellar: :any, arm64_linux:  "1ece1fad9ec319695e00b3255dd66db13a8c6bdb8e76cf1a81faeb1abd226034"
    sha256 cellar: :any, x86_64_linux: "6479ae658c17d36974839b7c264a7a4097ff8f41047c5752193c46970edc1122"
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
    assert_match(/^1  \(5,4,3\)$/, shell_output("#{bin}/lrcalc mult -f 3,2 3 2 1 - 3 2 1"))
  end
end
