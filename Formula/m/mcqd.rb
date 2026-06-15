class Mcqd < Formula
  desc "Fast exact algorithm for finding a maximum clique in an undirected graph"
  homepage "https://gitlab.com/janezkonc/mcqd"
  url "https://gitlab.com/dimpase/mcqd/-/archive/v1.0.2/mcqd-v1.0.2.tar.bz2"
  sha256 "2e5e368ac385f06e82cee78994b5f7646b6ea4786e12849765ccbebe226b97cd"
  license "GPL-3.0-only"

  depends_on "cmake" => :build

  def install
    build_path = "build"
    system "cmake", "-S", ".", "-B#{build_path}", "-DCMAKE_VERBOSE_MAKEFILE=ON",
      *std_cmake_args
    system "cmake", "--build", build_path
    system "cmake", "--install", build_path
  end

  test do
    system "true"
  end
end
