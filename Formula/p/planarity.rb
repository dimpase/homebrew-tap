class Planarity < Formula
  desc "Edge addition planarity suite: graph planarity testing and embedding"
  homepage "https://github.com/graph-algorithms/edge-addition-planarity-suite"
  url "https://github.com/graph-algorithms/edge-addition-planarity-suite/archive/refs/tags/Version_4.0.1.0.tar.gz"
  sha256 "94a6738cf4e5aaa912f0dd47b0b9b6a8022eccb9d668bd1d7d3de2fc920ec129"
  license "BSD-3-Clause"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-fi"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "planarity", shell_output("#{bin}/planarity -h 2>&1", 1)
  end
end
