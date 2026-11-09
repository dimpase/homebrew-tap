class GmpEcm < Formula
  desc "Elliptic Curve Method for Integer Factorization"
  homepage "https://gitlab.inria.fr/zimmerma/ecm"
  url "https://gitlab.inria.fr/zimmerma/ecm/-/archive/git-7.0.7/ecm-git-7.0.7.tar.gz"
  sha256 "cfc1c0745694e7b24a8a373d8e854f8ab42cff177dbd98beba3b093e3858ca8a"
  license all_of: ["GPL-3.0-or-later", "LGPL-3.0-or-later"]
  head "https://gitlab.inria.fr/zimmerma/ecm.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "libomp" if OS.mac?
  depends_on "primesieve"

  def install
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
        mpz_t n, f;
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
