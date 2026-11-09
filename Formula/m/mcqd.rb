class Mcqd < Formula
  desc "Fast exact algorithm for finding a maximum clique in an undirected graph"
  homepage "https://gitlab.com/janezkonc/mcqd"
  url "https://gitlab.com/dimpase/mcqd/-/archive/v1.0.2/mcqd-v1.0.2.tar.bz2"
  sha256 "2e5e368ac385f06e82cee78994b5f7646b6ea4786e12849765ccbebe226b97cd"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/mcqd-1.0.2"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "8a925235d73b871e29fe00c0e98530592c5aad5c175c0b394dec7058f5aab801"
    sha256 cellar: :any, arm64_linux:  "aaf13549d605ffdcbcad9bac8c22dc6b0b9b6ad2610c3adefaec65d8910461de"
    sha256 cellar: :any, x86_64_linux: "168e36a5f2b6e6501f1d383356c003e2be0d9258025d8e254aeb4152f4d95702"
  end

  depends_on "cmake" => :build

  def install
    build_path = "build"
    system "cmake", "-S", ".", "-B#{build_path}", "-DCMAKE_VERBOSE_MAKEFILE=ON",
      *std_cmake_args
    system "cmake", "--build", build_path
    system "cmake", "--install", build_path
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <mcqd.h>
      int main() {
        const bool adjacency[4][4] = {
          {false, true, true, false},
          {true, false, true, false},
          {true, true, false, true},
          {false, false, true, false}
        };
        const bool *rows[] = {adjacency[0], adjacency[1], adjacency[2], adjacency[3]};
        Maxclique graph(rows, 4);
        int *clique = nullptr, size = 0;
        graph.mcqdyn(clique, size);
        bool correct = size == 3;
        for (int i = 0; i < size; ++i)
          for (int j = i + 1; j < size; ++j)
            correct = correct && adjacency[clique[i]][clique[j]];
        delete[] clique;
        return !correct;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}", "-L#{lib}", "-lmcqd", "-o", "test"
    system "./test"
  end
end
