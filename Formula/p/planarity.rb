class Planarity < Formula
  desc "Edge addition planarity suite: graph planarity testing and embedding"
  homepage "https://github.com/graph-algorithms/edge-addition-planarity-suite"
  url "https://github.com/graph-algorithms/edge-addition-planarity-suite/archive/refs/tags/Version_4.0.1.0.tar.gz"
  sha256 "94a6738cf4e5aaa912f0dd47b0b9b6a8022eccb9d668bd1d7d3de2fc920ec129"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/planarity-4.0.1.0"
    sha256 cellar: :any,                 arm64_tahoe:  "d006f90232db4b206f2c222670aae9c3c88beb4966090320d662ee50d49c6319"
    sha256 cellar: :any,                 sequoia:      "966af94f3a86ba79256dddc533779eb2e721ceed4df4a0670d0746a4676e53fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "057eb8cf9dc89ea374415fb1a66759ae41804f60b57b27e5db3558e46d1a6105"
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
