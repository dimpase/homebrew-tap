class Planarity < Formula
  desc "Edge addition planarity suite: graph planarity testing and embedding"
  homepage "https://github.com/graph-algorithms/edge-addition-planarity-suite"
  url "https://github.com/graph-algorithms/edge-addition-planarity-suite/archive/refs/tags/Version_4.0.1.0.tar.gz"
  sha256 "94a6738cf4e5aaa912f0dd47b0b9b6a8022eccb9d668bd1d7d3de2fc920ec129"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/planarity-4.0.1.0"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "3cb8bf6225ed58c620f9cdd1c63b4e6c3151118c58d32b9322ec406fe8a3f87e"
    sha256 cellar: :any, arm64_linux:  "39fbc4f44264e248483095789bceb6aea416a82c15d8bbc36b273434ae670ed2"
    sha256 cellar: :any, x86_64_linux: "0b2f7bbfbe4b1ff42a98f6595f160141c4f5ba1497d92b7512e17bbceb312e9b"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-fi"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    # K4 (4-vertex complete graph) is planar; planarity returns 0 for planar
    (testpath/"k4.txt").write <<~EOS
      N=4
      0: 1 2 3 -1
      1: 0 2 3 -1
      2: 0 1 3 -1
      3: 0 1 2 -1
    EOS
    system bin/"planarity", "-s", "-q", "-p", testpath/"k4.txt", testpath/"k4.out"

    # K3,3 (complete bipartite 3,3) is non-planar; planarity returns 1 for non-planar
    (testpath/"k33.txt").write <<~EOS
      N=6
      0: 3 4 5 -1
      1: 3 4 5 -1
      2: 3 4 5 -1
      3: 0 1 2 -1
      4: 0 1 2 -1
      5: 0 1 2 -1
    EOS
    shell_output("#{bin}/planarity -s -q -p #{testpath}/k33.txt #{testpath}/k33.out 2>&1", 1)
  end
end
