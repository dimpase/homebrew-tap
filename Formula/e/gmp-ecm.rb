class GmpEcm < Formula
  desc "Elliptic Curve Method for Integer Factorization"
  homepage "https://gitlab.inria.fr/zimmerma/ecm"
  url "https://gitlab.inria.fr/zimmerma/ecm/-/archive/git-7.0.7/ecm-git-7.0.7.tar.gz"
  sha256 "cfc1c0745694e7b24a8a373d8e854f8ab42cff177dbd98beba3b093e3858ca8a"
  license all_of: ["GPL-3.0-or-later", "LGPL-3.0-or-later"]
  revision 1
  head "https://gitlab.inria.fr/zimmerma/ecm.git", branch: "master"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/gmp-ecm-7.0.7_1"
    sha256 cellar: :any, arm64_tahoe:  "6eba52befa7f944b4a07a81da5f7e5edb92541399ee4a80f36cdb5b175d0e25b"
    sha256 cellar: :any, arm64_linux:  "3221897b0637e3aed6bd4d72de101827587f56497bbc0fa75fbd561d627de19b"
    sha256 cellar: :any, x86_64_linux: "a0d2dfc0bd00befb4aa29c4df60755255f1352815f88c20156971dbe83c4d887"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gmp"

  on_macos do
    depends_on "libomp"
    depends_on "primesieve"
  end

  on_linux do
    depends_on "dimpase/tap/primesieve-portable"
  end

  def install
    if OS.linux?
      primesieve = Formula["dimpase/tap/primesieve-portable"]
      ENV.prepend "CPPFLAGS", "-I#{primesieve.opt_include}"
      ENV.prepend "LDFLAGS", "-L#{primesieve.opt_lib} -Wl,-rpath,#{primesieve.opt_lib}"
    end

    system "autoreconf", "--force", "--install"
    system "./configure", "--enable-openmp", "--enable-shared", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    # Test the ecm binary: factor 121 = 11 * 11
    assert_match "Factor found", pipe_output("#{bin}/ecm 100", "121\n")

    # Test P-1 with fixed base 2 and B1=5: gcd(2^60 - 1, 3937) = 31,
    # because 2 has order 5 modulo 31 and order 7 modulo 127.
    # Random bases can return the whole composite instead.
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <stdlib.h>
      #include <gmp.h>
      #include <ecm.h>

      int main(void) {
        mpz_t n, f, expected;
        ecm_params q;

        mpz_init_set_ui(n, 3937);
        mpz_init(f);
        ecm_init(q);

        q->method = ECM_PM1;
        mpz_set_ui(q->x, 2);
        mpz_set_ui(q->B2, 0); /* Disable stage 2. */

        int ret = ecm_factor(f, n, 5.0, q);
        if (ret != ECM_FACTOR_FOUND_STEP1 || mpz_cmp_ui(f, 31) != 0) {
          gmp_fprintf(stderr, "Unexpected P-1 result: status=%d, factor=%Zd\\n", ret, f);
          return 1;
        }

        ecm_clear(q);

        /* Sage's deterministic 128-bit ECM case exercises primesieve and stage 2. */
        mpz_ui_pow_ui(n, 2, 128);
        mpz_add_ui(n, n, 1);
        mpz_init_set_str(expected, "5704689200685129054721", 10);
        ecm_init(q);
        q->method = ECM_ECM;
        q->param = ECM_PARAM_SUYAMA;
        q->sigma_is_A = 0;
        mpz_set_ui(q->sigma, 227140902);
        mpz_set_ui(q->B2, 51606);

        ret = ecm_factor(f, n, 1000.0, q);
        if (ret != ECM_FACTOR_FOUND_STEP2 || mpz_cmp(f, expected) != 0) {
          gmp_fprintf(stderr, "Unexpected ECM result: status=%d, factor=%Zd\\n", ret, f);
          return 1;
        }

        ecm_clear(q);
        mpz_clear(expected);
        mpz_clear(f);
        mpz_clear(n);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test",
           "-I#{include}", "-L#{lib}", "-L#{Formula["gmp"].lib}",
           "-lecm", "-lgmp"
    system "./test"
  end
end
