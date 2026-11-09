class Rw < Formula
  desc "Program to calculate rank-width and rank-decompositions"
  homepage "https://sourceforge.net/projects/rankwidth"
  url "https://downloads.sourceforge.net/project/rankwidth/rw-0.10.tar.gz"
  sha256 "89a8ed364893ac1b70ab70a152e3e7db3cf348bb69098aa6dbb969639df927db"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/rw-0.10"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "c3dbb142f8b67c13145f156cf4e3c3c379eec91d2d603e9ba2707cc581570b65"
    sha256 cellar: :any, arm64_linux:  "d220a74e7a3101b2028aa37836f1d3d086e176ec3b2671d6328b28679b2282cc"
    sha256 cellar: :any, x86_64_linux: "d84c7d6bd6e2b2ff50b08cf30d7ac89d9b5f41f5d018d81cdb864bb29cbf964a"
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
