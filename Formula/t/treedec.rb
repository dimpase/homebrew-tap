class Treedec < Formula
  desc "Algorithms concerning tree decompositions"
  homepage "https://github.com/freetdi/tdlib"
  url "https://github.com/freetdi/tdlib/archive/refs/tags/0.9.3.tar.gz"
  sha256 "d1730c98f41dcb23bbd0bd8de9dbec51df015304f28a38935848925901594ae8"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/treedec-0.9.3"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2b3a2fdd5d350a5eb7b4acddcf7a06894a86b7df264bacb086cd07fd3bc4e8dc"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "d0c4474dd92bfd484daeb4707d88e266d775d51cf90e9b26e6eb12c33ad54d9d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ae4e055dd942aa14bce3787fdfc33716fd08faff2811164ea319a89eeec54d00"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "boost"

  patch :DATA

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--with-python=no", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <boost/graph/adjacency_list.hpp>
      #include <treedec/combinations.hpp>
      int main() {
        using Graph = boost::adjacency_list<boost::setS, boost::vecS, boost::undirectedS>;
        Graph graph(4);
        for (unsigned i = 0; i < 4; ++i) boost::add_edge(i, (i + 1) % 4, graph);
        TD_tree_dec_t decomposition;
        treedec::exact_decomposition_cutset(graph, decomposition);
        return treedec::get_width(decomposition) != 2;
      }
    EOS
    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{include}",
           "-I#{formula_opt_include("boost")}", "-o", "test"
    system "./test"
  end
end

__END__


From f9bea896a49ef909aeb910c140661ab06b3b6a0b Mon Sep 17 00:00:00 2001
From: Matthias Koeppe <mkoeppe@math.ucdavis.edu>
Date: Fri, 7 Jun 2024 12:21:28 -0700
Subject: [PATCH] src/exact_cutset.hpp: Suppress 'incomplete' message

---
 src/exact_cutset.hpp | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/exact_cutset.hpp b/src/exact_cutset.hpp
index 782bb96..2caa7bd 100755
--- a/src/exact_cutset.hpp
+++ b/src/exact_cutset.hpp
@@ -994,7 +994,7 @@ bool exact_cutset<G_t, config>::try_it(T_t &T, unsigned bagsize)
     }else{
      //   incomplete(); //no//
      // messes up random tests, send to cerr instead
-        std::cerr << "incomplete ../../src/exact_cutset.hpp:978:try_it\n";
+     //   std::cerr << "incomplete ../../src/exact_cutset.hpp:978:try_it\n";
     }
 
     typename boost::graph_traits<G_t>::vertex_iterator vIt, vEnd;
-- 
2.42.0

