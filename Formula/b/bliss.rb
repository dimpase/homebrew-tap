class Bliss < Formula
  desc "Computing automorphism groups and canonical forms of graphs"
  homepage "https://users.aalto.fi/~tjunttil/bliss/index.html"
  url "https://users.aalto.fi/~tjunttil/bliss/downloads/bliss-0.77.zip"
  sha256 "acc8b98034f30fad24c897f365abd866c13d9f1bb207e398d0caf136875972a4"
  license "LGPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/bliss-0.77"
    rebuild 2
    sha256 cellar: :any, arm64_tahoe:  "4be4dcfc7631ea63fd680a6b60bca4696dc663df0ece901479397733fc951f54"
    sha256 cellar: :any, arm64_linux:  "47106389ca994844a8c0337a0e98b79e0bfe3dd5c96e1959214ca4e9bd675abe"
    sha256 cellar: :any, x86_64_linux: "f5882c655633f770603ddc1611a4bd7b565c30989c6ee15d03c3944c9c025d70"
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
    (testpath/"cycle4.dimacs").write <<~EOS
      p edge 4 4
      e 1 2
      e 2 3
      e 3 4
      e 4 1
    EOS
    output = shell_output("#{bin}/bliss -can #{testpath}/cycle4.dimacs")
    assert_match(/\|Aut\|:\s+8\b/, output)
    assert_match "Canonical labeling:", output
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
