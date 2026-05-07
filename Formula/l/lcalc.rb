class Lcalc < Formula
  desc "Package for working with L-functions"
  homepage "https://gitlab.com/sagemath/lcalc"
  url "https://gitlab.com/-/project/12934202/uploads/0bcf82cdd02412faf9ec0cf80e656610/lcalc-2.2.1.tar.xz"
  sha256 "aa2c3979b12e12df2ecb681c1a25a0f5a3811c195f61a3baa7512fef1460c40f"
  license "GPL-2.0-only"

  depends_on "gengetopt" => :build
  depends_on "libtool" => :build
  depends_on "libomp" if OS.mac?
  depends_on "libpng"

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    system "./configure", "--enable-openmp", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    if OS.mac?
      require "utils/linkage"
      libomp = Formula["libomp"].opt_lib/"libomp.dylib"
      assert Utils.binary_linked_to_library?(lib/"libLfunction.dylib", libomp), "Missing linkage to libomp!"
    end

    (testpath/"test.cc").write <<~EOS
      /* from https://gitlab.com/sagemath/lcalc/-/blob/master/doc/examples/example.cc */
      #include "lcalc/L.h"

      int main (int argc, char *argv[]) {
          // Initialize global variables. This *must* be called.
          initialize_globals();

          Double x,y;
          Complex s;

          // Will hold the default L-function, the Riemann zeta function.
          L_function<int> zeta;

          // Will be assigned below to be L(s,chi_{-4}), chi{-4} being the
          // real quadratic character mod 4.
          L_function<int> L4;

          // Will be assigned below to be L(s,chi), with chi being a complex
          // character mod 5.
          L_function<Complex> L5;


          // ==================== Initialize the L-functions ===============
          //
          // one drawback of arrays- the index starts at 0 rather than 1 so
          // each array below is declared to be one entry larger than it is.
          // I prefer this so that referring to the array elements is more
          // straightforward, for example coeff[1] refers to the first
          // Dirichlet cefficient rather than coeff[0]. But to make up for
          // this, we insert a bogus entry (such as 0) at the start of each
          // array.
          //

          // The Dirichlet coefficients, periodic of period 4.
          int coeff_L4[] = {0,1,0,-1,0};

          // The gamma factor Gamma(gamma s + lambda) is Gamma(s/2+1/2)
          Double gamma_L4[] = {0,.5};

          Complex lambda_L4[] = {0,.5}; // The lambda
          Complex pole_L4[] = {0}; // No pole
          Complex residue_L4[] = {0}; // No residue

          // On the next line:
          //
          // "L4" is the name of the L-function
          //  1 - what_type, 1 stands for periodic Dirichlet coefficients
          //  4 - N_terms, number of Dirichlet coefficients given
          //  coeff_L4  - array of Dirichlet coefficients
          //  4 - period (0 if coeffs are not periodic)
          //  sqrt(4/Pi) - the Q^s that appears in the functional equation
          //  1 - sign of the functional equation
          //  1 - number of gamma factors of the form Gamma(gamma s + lambda), gamma = .5 or 1
          //  gamma_L4  - array of gamma's (each gamma is .5 or 1)
          //  lambda_L4  - array of lambda's (given as complex numbers)
          //  0 - number of poles. Typically there won't be any poles.
          //  pole_L4 - array of poles, in this case none
          //  residue_L4 - array of residues, in this case none
          //
          //  Note: one can call the constructor without the last three
          //  arguments when number of poles is zero, as in:
          //
          //  L4 = L_function<int>("L4",1,4,coeff_L4,4,sqrt(4/Pi),1,1,gamma_L4,lambda_L4);
          //
          L4=L_function<int>("L4",1,4,coeff_L4,4,sqrt(4/Pi),1,1,gamma_L4,lambda_L4,0,pole_L4,residue_L4);

          Complex coeff_L5[6] = {0,1,I,-I,-1,0};

          Complex gauss_sum = 0;
          for(int n=1;n<=4; n++) {
            gauss_sum = gauss_sum+coeff_L5[n]*exp(n*2*I*Pi/5);
          }


          // On the next line:
          //
          // "L5" is the name of the L-function
          //  1 - what_type, 1 stands for periodic Dirichlet coefficients
          //  5 - N_terms, number of Dirichlet coefficients given
          //  coeff_L5  - array of Dirichlet coefficients
          //  5 - period (0 if coeffs are not periodic)
          //  sqrt(5/Pi), the Q^s that appears in the functional equation
          //  gauss_sum/sqrt(5) - omega of the functional equation
          //  1 - number of gamma factors of the form Gamma(gamma s + lambda), gamma = .5 or 1
          //  gamma_L4  - L5 has same gamma factor as L4
          //  lambda_L4  - ditto
          L5=L_function<Complex>("L5",1,5,coeff_L5,5,sqrt(5/Pi),gauss_sum/(I*sqrt(5.)),1,gamma_L4,lambda_L4);



          // Print some basic data for the L-functions
          zeta.print_data_L();
          L4.print_data_L();
          L5.print_data_L();

          // Print some L-values
          x = 0.5; y = 0;
          cout << "zeta" << x+I*y << " = " << zeta.value(x+I*y) << endl;
          cout << "L4"   << x+I*y << " = " << L4.value(x+I*y)   << endl;
          cout << "L5"   << x+I*y << " = " << L5.value(x+I*y)   << endl;

          x = 1; y = 0;
          cout << "L4" << x+I*y << " = " << L4.value(x+I*y) << endl;
          cout << "L5" << x+I*y << " = " << L5.value(x+I*y) << endl;

          // =========== find and print some zeros=============================
          // Find zeros of zeta up to height 100 taking steps of size .1,
          // looking for sign changes on the critical line. Some zeros can
          // be missed in this fashion.  First column gives the imaginary
          // part of the zeros.  Second column outputted is related to S(T)
          // and should be small on average (larger values means zeros were
          // missed).
          zeta.find_zeros(Double(0),Double(100),Double(.1));

          // Find the first 100 zeros of zeta. This also verifies RH and
          // does not omit zeros. This ill *not* look for zeros below the
          // real axis as they come in conjugate pairs.
          zeta.find_zeros(100);

          // Do the same for L4 and L5.
          L4.find_zeros(Double(0),Double(100),Double(.1));
          L4.find_zeros(100);

          L5.find_zeros(Double(0),Double(100),Double(.1));

           // This *will* look for zeros above and below the real axis since
           // is not self-dual
          L5.find_zeros(100);

          return 0;
      }
    EOS
    system ENV.cxx, "test.cc", "-I#{include}", "-L#{lib}", "-lLfunction", "-o", "test"
    system "./test"
  end
end
