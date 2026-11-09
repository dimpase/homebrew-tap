class Cliquer < Formula
  desc "Routines for clique searching in weighted graphs"
  homepage "https://github.com/dimpase/autocliquer"
  url "https://github.com/dimpase/autocliquer/releases/download/v1.23/cliquer-1.23.tar.gz"
  sha256 "c1d7cc927b7efe76ff4f11e1f01bee473e37360fb54843b16b287e3ad161287b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/cliquer-1.23"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "b0130cae45cff33769c6034ef4828ebdbd1e751929735b01da1e0309d7dd1a2c"
    sha256 cellar: :any, arm64_linux:  "37ca43cf4416e1b9ffd1d7a3a07e3228020b5c01f8d3d58352951d01f8c3e26e"
    sha256 cellar: :any, x86_64_linux: "1858cd82387bbeabbc81168f0ca0b81906de24fde56d4cd2cea31bd08da3315e"
  end

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
