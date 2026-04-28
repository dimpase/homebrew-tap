class Cliquer < Formula
  desc "Routines for clique searching in weighted graphs"
  homepage "https://github.com/dimpase/autocliquer"
  url "https://github.com/dimpase/autocliquer/releases/download/v1.23/cliquer-1.23.tar.gz"
  sha256 "c1d7cc927b7efe76ff4f11e1f01bee473e37360fb54843b16b287e3ad161287b"
  license "GPL-2.0-or-later"

  depends_on "libtool" => :build

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cliquer/cliquer.h>

      int main(void) {
        graph_t *g = graph_new(3);
        GRAPH_ADD_EDGE(g, 0, 1);
        GRAPH_ADD_EDGE(g, 1, 2);
        GRAPH_ADD_EDGE(g, 0, 2);
        set_t s = clique_find_single(g, 0, 0, FALSE, clique_default_options);
        graph_free(g);
        set_free(s);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcliquer", "-o", "test"
    system "./test"
  end
end
