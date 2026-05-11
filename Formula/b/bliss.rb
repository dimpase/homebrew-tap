class Bliss < Formula
  desc "Computing automorphism groups and canonical forms of graphs"
  homepage "https://users.aalto.fi/~tjunttil/bliss/index.html"
  url "https://users.aalto.fi/~tjunttil/bliss/downloads/bliss-0.77.zip"
  sha256 "acc8b98034f30fad24c897f365abd866c13d9f1bb207e398d0caf136875972a4"
  license "LGPL-3.0-only"

  depends_on "cmake" => :build

  patch :DATA

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "cmake", ".", *std_cmake_args
    system "make", "install"
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
