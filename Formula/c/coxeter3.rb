class Coxeter3 < Formula
  desc "Fokko Ducloux's Coxeter 3 C++ library"
  homepage "https://github.com/tscrim/coxeter"
  url "https://github.com/dimpase/coxeter/archive/refs/tags/v3.1.tar.gz"
  sha256 "46bc9ae200bd0eb81e50f5e20fbd6a1ba6c17e04d3046d541f2e50b5b9ca5c32"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/coxeter3-3.1"
    sha256 cellar: :any, arm64_tahoe:  "d931993425ce84da769b42dd8d3cdda44ea73982b627805339c261fd24f07739"
    sha256 cellar: :any, sequoia:      "b1af0bd962c4ca799b63b4dc884fef0cbd3fe33f14254fb3e9589d3429534bde"
    sha256 cellar: :any, x86_64_linux: "7835ff8d16c4cba233bbbe2c3a8acc9323301129580c33b4f7769aa548c4b3ab"
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
