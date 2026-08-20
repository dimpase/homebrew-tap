class Bliss < Formula
  desc "Computing automorphism groups and canonical forms of graphs"
  homepage "https://users.aalto.fi/~tjunttil/bliss/index.html"
  url "https://users.aalto.fi/~tjunttil/bliss/downloads/bliss-0.77.zip"
  sha256 "acc8b98034f30fad24c897f365abd866c13d9f1bb207e398d0caf136875972a4"
  license "LGPL-3.0-only"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/bliss-0.77"
    sha256 cellar: :any,                 arm64_tahoe:  "445e5a788ef2deda1d3cb313295c097eef298b3be8675c7d857fa2980c5a2d3a"
    sha256 cellar: :any,                 sequoia:      "0bc5164c6985847487392b0ee07802279e8d2e536d05d38dc932b19691d55d07"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "821919cd37c2a3433b3fdbdc4afe3e3132516e0a5673c85115ffa3a7d35f0f7b"
  end

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
