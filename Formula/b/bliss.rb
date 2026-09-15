class Bliss < Formula
  desc "Computing automorphism groups and canonical forms of graphs"
  homepage "https://users.aalto.fi/~tjunttil/bliss/index.html"
  url "https://users.aalto.fi/~tjunttil/bliss/downloads/bliss-0.77.zip"
  sha256 "acc8b98034f30fad24c897f365abd866c13d9f1bb207e398d0caf136875972a4"
  license "LGPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/bliss-0.77"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "4a8b08630c023221bed4da42c97db6b737815f78bbd660e95d5f9083496ead29"
    sha256 cellar: :any, sequoia:      "c6c2754ea2afd9926c56d927b18c30cb22635c9b6d83e5a44ec8767051bf1840"
    sha256 cellar: :any, x86_64_linux: "10eeee767fd0545f7a6931b4591d2f04ac769439322a097c389f5ed4e39eb3c2"
  end

  depends_on "cmake" => :build

  patch :DATA

  def install
    build_path = "build"
    system "cmake", "-S", ".", "-B", build_path, *std_cmake_args
    system "cmake", "--build", build_path
    system "cmake", "--install", build_path
  end

  test do
    system "true"
  end
end

__END__

diff --git a/CMakeLists.txt b/CMakeLists.txt
index 01ed093..cfdb0a6 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -62,3 +62,27 @@ if(USE_GMP)
   target_link_libraries(bliss-executable ${GMP_LIBRARIES})
 endif(USE_GMP)
 set_target_properties(bliss-executable PROPERTIES OUTPUT_NAME bliss)
+
+include(GNUInstallDirs)
+
+set(
+  BLISS_HEADERS
+  src/bliss_C.h
+  src/uintseqhash.hh
+  src/abstractgraph.hh
+  src/stats.hh
+  src/digraph.hh
+  src/defs.hh
+  src/heap.hh
+  src/graph.hh
+  src/partition.hh
+  src/kqueue.hh
+  src/utils.hh
+  src/orbit.hh
+  src/timer.hh
+  src/bignum.hh
+)
+
+install(TARGETS bliss-executable RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
+install(TARGETS bliss LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
+install(FILES ${BLISS_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/bliss)
