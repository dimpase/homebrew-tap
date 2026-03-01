# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class M4rie < Formula
  desc "M4RIE is a library for fast arithmetic with dense matrices over GF(2^e) for 2 ≤ e ≤ 16"
  homepage "https://bitbucket.org/malb/m4rie"
  url "https://github.com/malb/m4rie/releases/download/20250128/m4rie-20250128.tar.gz"
  sha256 "96f1adafd50e6a0b51dc3aa1cb56cb6c1361ae7c10d97dc35c3fa70822a55bd7"
  license "GPL-2.0"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libpng"
  depends_on "m4ri"


  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    (testpath/"test.c").write <<~EOS
/* from https://gist.githubusercontent.com/malb/163f1acf92305e7951e887e50b82a931/raw/774d4fd42825d1432178a8a1f0f62ad20f664423/test.c */
#include <m4rie/m4rie.h>

const size_t d = 3;
const size_t m = 1024;
const size_t n = 1024;
const size_t l = 1024;

/*
  compile with:
  gcc test.c -I. -L. -lm4rie -lm4ri -lm -o test
 */

int mzed_test(const size_t d, const size_t m, const size_t n, const size_t l) {
  gf2e *ff = gf2e_init(irreducible_polynomials[d][1]);

  mzed_t *A = mzed_init(ff, m, n);
  mzed_randomize(A);
  mzed_t *B = mzed_init(ff, m, n);
  mzed_randomize(B);
  mzed_t *C = mzed_init(ff, n, l);
  mzed_randomize(C);

  // AC + BC = (A+B)C
  mzed_t *R0 = mzed_mul(NULL, A, C);
  mzed_addmul(R0, B, C);

  mzed_t *T0 = mzed_add(NULL, A, B);
  mzed_t *R1 = mzed_mul(NULL, T0, C);

  int r = mzed_cmp(R0, R1);

  mzed_free(R1);
  mzed_free(T0);
  mzed_free(R0);
  mzed_free(C);
  mzed_free(B);
  mzed_free(A);

  return r;
}

int mzd_slice_test(const size_t d, const size_t m, const size_t n,
                   const size_t l) {
  gf2e *ff = gf2e_init(irreducible_polynomials[d][1]);

  mzd_slice_t *A = mzd_slice_init(ff, m, n);
  mzd_slice_randomize(A);
  mzd_slice_t *B = mzd_slice_init(ff, m, n);
  mzd_slice_randomize(B);
  mzd_slice_t *C = mzd_slice_init(ff, n, l);
  mzd_slice_randomize(C);

  // AC + BC = (A+B)C
  mzd_slice_t *R0 = mzd_slice_mul(NULL, A, C);
  mzd_slice_addmul(R0, B, C);

  mzd_slice_t *T0 = mzd_slice_add(NULL, A, B);
  mzd_slice_t *R1 = mzd_slice_mul(NULL, T0, C);

  int r = mzd_slice_cmp(R0, R1);

  mzd_slice_free(R1);
  mzd_slice_free(T0);
  mzd_slice_free(R0);
  mzd_slice_free(C);
  mzd_slice_free(B);
  mzd_slice_free(A);

  return r;
}

int main(int argc, char *argv[]) {
  int r0 = mzed_test(d, m, n, l);
  int r1 = mzd_slice_test(d, m, n, l);

  if (r0 | r1) {
    fprintf(stderr, "M4RIE test failed.");
    return -1;
  } else {
    fprintf(stderr, "M4RIE test passed.");
    return 0;
  }
}
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lm4rie", "-L#{Formula["m4ri"].lib}", "-lm4ri", "-o", "test"
    system "./test"
  end
end
