class Coxeter3 < Formula
  desc "Fokko Ducloux's Coxeter 3 C++ library"
  homepage "https://github.com/tscrim/coxeter"
  url "https://github.com/dimpase/coxeter/archive/refs/tags/v3.1.tar.gz"
  sha256 "46bc9ae200bd0eb81e50f5e20fbd6a1ba6c17e04d3046d541f2e50b5b9ca5c32"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/coxeter3-3.1"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "91ba81565c724a4e8ffd74d3fc591c1c746adcb83e53fde043ae46ed2017abef"
    sha256 cellar: :any, arm64_linux:  "7cb186d958c54a7bdfa7084d59e92d619a90798c32ff3dd5f9951e0c302a1155"
    sha256 cellar: :any, x86_64_linux: "b752c2830c517c7cdb955d0663db77c30d87d8de1f1efed6d3810bd6618a7b6b"
  end

  depends_on "libtool" => :build

  def install
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.input").write <<~COXETER
      type
      A
      3
      compute
      1 3 2 1 2 3 1 2 1
      ihbetti
      213
      q
      q
    COXETER
    assert_match "size : 8", shell_output("#{bin}/coxeter < #{testpath}/test.input | grep 'size : 8$'")
  end
end
