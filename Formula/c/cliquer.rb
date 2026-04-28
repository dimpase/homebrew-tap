class Cliquer < Formula
  desc "Routines for clique searching in weighted graphs"
  homepage "https://github.com/dimpase/autocliquer"
  url "https://github.com/dimpase/autocliquer/archive/refs/tags/v1.23.tar.gz"
  sha256 "089b06d8898a6cf55db3ee100888d1c0099e083db93eba5d1440bfe85ad85b11"
  license "GPL-2.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-ivf"
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
