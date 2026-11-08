class Rw < Formula
  desc "Program to calculate rank-width and rank-decompositions"
  homepage "https://sourceforge.net/projects/rankwidth"
  url "https://downloads.sourceforge.net/project/rankwidth/rw-0.10.tar.gz"
  sha256 "89a8ed364893ac1b70ab70a152e3e7db3cf348bb69098aa6dbb969639df927db"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/rw-0.10"
    sha256 cellar: :any,                 arm64_tahoe:  "51925dcc2373fbfebc68b916ed522a814cb32c70c022c3cc805a4a789125b886"
    sha256 cellar: :any,                 sequoia:      "f2eb17bafcdfb9414c3ac6f26ab5893dbdc4642d45e50c1275a3c437fff9c385"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9f4a593f9fa1e90ebbd725c531c5278684837faca1394ddeeda29b38d3b2a028"
  end

  depends_on "libtool" => :build

  def install
    system "./configure", "--disable-executable", "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <rw.h>
      int main(void) {
        if (init_rw_dec(5)) return 1;
        for (unsigned i = 0; i < 5; ++i)
          adjacency_matrix[i] = (1U << ((i + 1) % 5)) | (1U << ((i + 4) % 5));
        calculate_all();
        unsigned width = get_rw();
        destroy_rw();
        /* A cycle on five vertices has rank-width two. */
        return width != 2;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lrw", "-o", "test"
    system "./test"
  end
end
