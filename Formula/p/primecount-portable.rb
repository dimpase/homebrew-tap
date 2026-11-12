class PrimecountPortable < Formula
  desc "Fast prime counting function program and C/C++ library"
  homepage "https://github.com/kimwalisch/primecount"
  url "https://github.com/kimwalisch/primecount/archive/refs/tags/v9.0.tar.gz"
  sha256 "0fcc2083a476708f5cf1728dc8a64be60d8f7ca1dc623039889e67f70da048eb"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/primecount-portable-9.0"
    sha256 cellar: :any, arm64_tahoe:  "a5bc73739ab6ab6d21209a00e1a31ecc33838962481ca01cbe5228b3d8063e7d"
    sha256 cellar: :any, arm64_linux:  "f51e57256e03e9a7346960effd8727a262e3669eb2403d0163f3c61bd3b0065e"
    sha256 cellar: :any, x86_64_linux: "35dadb4ec1e2982d831c0d1d1f28de4d381e368d7506003c0bfce99d73100760"
  end

  keg_only "to use Sage's portable primesieve without replacing Homebrew core"

  depends_on "cmake" => :build
  depends_on "dimpase/tap/primesieve-portable"

  on_macos do
    depends_on "libomp"
  end

  deny_network_access!

  def install
    primesieve_cmake = formula_opt_lib("dimpase/tap/primesieve-portable")/"cmake/primesieve"
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON",
                                              "-DBUILD_LIBPRIMESIEVE=OFF",
                                              "-Dprimesieve_DIR=#{primesieve_cmake}",
                                              "-DCMAKE_INSTALL_RPATH=#{rpath}",
                                              *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_equal "37607912018\n", shell_output("#{bin}/primecount 1e12")
    assert_equal "50847534\n", shell_output("#{bin}/primecount 1e9 --primesieve --threads=1")
    (testpath/"test.cpp").write <<~CPP
      #include <primecount.hpp>
      #include <cstdint>
      int main() {
        primecount::set_num_threads(1);
        if (primecount::pi(int64_t{1000000000000}) != 37607912018)
          return 1;
        return primecount::nth_prime(int64_t{1000000}) == 15485863 ? 0 : 2;
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++14", "-I#{include}", "-L#{lib}",
                   "-Wl,-rpath,#{lib}", "-lprimecount", "-o", "test"
    system "./test"
  end
end
