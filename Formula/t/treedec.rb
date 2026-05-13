class Treedec < Formula
  desc "Algorithms concerning tree decompositions"
  homepage "https://github.com/freetdi/tdlib"
  url "https://github.com/freetdi/tdlib/archive/refs/tags/0.9.3.tar.gz"
  sha256 "d1730c98f41dcb23bbd0bd8de9dbec51df015304f28a38935848925901594ae8"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  patch :DATA

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--with-python=no", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system "true"
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

