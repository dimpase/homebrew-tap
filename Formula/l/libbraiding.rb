class Libbraiding < Formula
  desc "Computing with braids"
  homepage "https://github.com/miguelmarco/libbraiding"
  url "https://github.com/miguelmarco/libbraiding/releases/download/1.3.2/libbraiding-1.3.2.tar.gz"
  sha256 "d43a32e7770d5c9a89ae489c5ac353da9610a761f76745382cf7612eab046ffd"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/libbraiding-1.3.2"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "f9d1ae07cf7756e0265e2976f8c11e98c37807dfaae4e35385db354deba8aafa"
    sha256 cellar: :any, arm64_linux:  "4eef3fe5ef2ecafa4057cfd342f7f83bf50727999c301a09f58bb8adebf1590f"
    sha256 cellar: :any, x86_64_linux: "c99a86219d823764e9a0c69cabaa2c1c1467529e6bcd836dce292f2cfceb18d3"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf"

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <braiding.h>
      int main() {
        auto left = Braiding::WordToBraid({1, 2, 1}, 3);
        auto right = Braiding::WordToBraid({2, 1, 2}, 3);
        auto different = Braiding::WordToBraid({1, 1, 1}, 3);
        return left != right || left == different;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}", "-L#{lib}", "-lbraiding", "-o", "test"
    system "./test"
  end
end
