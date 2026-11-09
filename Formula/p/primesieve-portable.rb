class PrimesievePortable < Formula
  desc "Prime number generator with portable ARM SIMD dispatch"
  homepage "https://github.com/kimwalisch/primesieve"
  url "https://github.com/kimwalisch/primesieve/archive/refs/tags/v12.17.tar.gz"
  sha256 "c18fe8cef84d3cb4f1f5f37d3737999c00489fddc1b58327b61d1e31c9a5b49c"
  license "BSD-2-Clause"
  compatibility_version 1

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/primesieve-portable-12.17"
    sha256 cellar: :any, arm64_tahoe:  "3cbd3d5f7b348935c4467b096086a40e0c99254c10ff147b72be8c33c07e29b6"
    sha256 cellar: :any, arm64_linux:  "0814ea3145931a8e42ea0f276aa8cec00a66f9ced8aee1c04f404d6ad82c3c68"
    sha256 cellar: :any, x86_64_linux: "e67197a208f4626b798d3a6b108677962ac6304eb44edfec1b983b9eda06d4ea"
  end

  keg_only "to keep Sage's portable SIMD build separate from Homebrew core"

  depends_on "cmake" => :build

  # GCC 13 leaks the SVE helpers' target options into the baseline fallback.
  # Restore the previous options while retaining runtime SVE dispatch.
  patch :DATA

  deny_network_access!
  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_TESTS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}", *std_cmake_args
    system "cmake", "--build", "build"
    system "ctest", "--test-dir", "build", "--output-on-failure"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"primesieve", "--cpu-info"
    system bin/"primesieve", "--test"
    (testpath/"test.cpp").write <<~CPP
      #include <primesieve.hpp>
      int main() {
        primesieve::set_num_threads(1);
        if (primesieve::count_primes(0, 1000000) != 78498)
          return 1;
        return primesieve::nth_prime(10000) == 104729 ? 0 : 2;
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++14", "-I#{include}", "-L#{lib}",
                   "-Wl,-rpath,#{lib}", "-lprimesieve", "-o", "test"
    system "./test"
  end
end

__END__
--- a/src/PreSieve_arm_sve.hpp
+++ b/src/PreSieve_arm_sve.hpp
@@ -17,0 +18,5 @@
+
+#if defined(ENABLE_MULTIARCH_ARM_SVE) && \
+    defined(__GNUC__) && !defined(__clang__)
+  #pragma GCC push_options
+#endif
@@ -64,0 +70,3 @@
+#if defined(ENABLE_MULTIARCH_ARM_SVE) && \
+    defined(__GNUC__) && !defined(__clang__)
+  #pragma GCC pop_options
@@ -65,0 +74,2 @@
+
+#endif
--- a/cmake/multiarch_arm_sve.cmake
+++ b/cmake/multiarch_arm_sve.cmake
@@ -30,0 +31,4 @@
+    #if defined(__GNUC__) && !defined(__clang__)
+      #pragma GCC push_options
+    #endif
+
@@ -48,0 +53,4 @@
+
+    #if defined(__GNUC__) && !defined(__clang__)
+      #pragma GCC pop_options
+    #endif
