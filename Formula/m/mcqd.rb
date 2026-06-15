class Mcqd < Formula
  desc "Fast exact algorithm for finding a maximum clique in an undirected graph"
  homepage "https://gitlab.com/janezkonc/mcqd"
  url "https://gitlab.com/dimpase/mcqd/-/archive/v1.0.2/mcqd-v1.0.2.tar.bz2"
  sha256 "2e5e368ac385f06e82cee78994b5f7646b6ea4786e12849765ccbebe226b97cd"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/mcqd-1.0.2"
    sha256 cellar: :any, arm64_tahoe:  "42af2021aace19818fbb80968f94b083b04e14019d5b26fb5c105dccb6554a53"
    sha256 cellar: :any, sequoia:      "a1c7b93466a3ca1d156ce82abb9c5d56ccd1b7bed130056f661505e058d9686a"
    sha256 cellar: :any, x86_64_linux: "92cae27944d032b18e47a733c965b3959d0ba7e6c639b66cb1838f3627dd78ff"
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
    system "true"
  end
end
