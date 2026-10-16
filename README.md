# Dimpase's Tap

## How do I install these formulae?

`brew install dimpase/tap/<formula>`

Or `brew tap dimpase/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "dimpase/tap"
brew "<formula>"
```

## Platforms

SageMath and `sagemath-deps` have bottles for **macOS 26 (Tahoe) on Apple Silicon**,
**Linux ARM64** and **Linux x86-64**. Some libraries also have bottles for
**macOS 15 (Sequoia) on Intel**. Availability varies by formula.

## SageMath

`brew install dimpase/tap/sagemath` installs sagelib, the `sage` command and its
Jupyter kernel. It uses the separately bottled `sagemath-deps` environment, so
updating sagelib does not rebuild its Python dependencies.

`sagemath-deps` provides the native libraries, Python dependencies, data packages
and build tools needed to build sagelib separately. To install these dependencies:

```sh
brew install dimpase/tap/sagemath-deps
```

The Python packages are available to Homebrew Python 3.14 on macOS and Linux,
and also Python 3.13 on macOS. A virtual environment can use these packages with
`--system-site-packages`:

```sh
"$(brew --prefix python@3.14)/bin/python3.14" -m venv --system-site-packages sage-venv
source sage-venv/bin/activate
source "$(brew --prefix sagemath-deps)/share/sagemath-deps/python3.14-env.sh"

# From your Sage checkout:
python -m pip install --no-build-isolation --no-deps -e . \
  -Csetup-args=-Dbuild-docs=false -Csetup-args=--wrap-mode=nofallback
```

The environment script exposes the native headers, libraries and build tools,
including Cython, that a pip build needs outside Homebrew. It preserves the
active virtual environment's interpreter and tools. Source it again when opening
a new development shell. On macOS, replace `3.14` with `3.13` throughout to use
Python 3.13. The dependency set matches the Sage version in the formula; newer
checkouts may require additional dependencies. Documentation is built separately.

## Formulae and bottle downloads

Formula names link to the build recipes; version numbers link to the current
bottle releases.

### SageMath and Python packages

* [sagemath](Formula/s/sagemath.rb) [11.0.beta1_2](https://github.com/dimpase/homebrew-tap/releases/tag/sagemath-11.0.beta1_2) — Sagelib, the Sage command and Jupyter kernel.
* [sagemath-deps](Formula/s/sagemath-deps.rb) [11.0.beta1](https://github.com/dimpase/homebrew-tap/releases/tag/sagemath-deps-11.0.beta1) — Native and Python dependencies for Sage and development venvs.
* [cvxopt](Formula/c/cvxopt.rb) [1.3.3](https://github.com/dimpase/homebrew-tap/releases/tag/cvxopt-1.3.3) — Convex optimization.
* [cypari2](Formula/c/cypari2.rb) [2.2.6](https://github.com/dimpase/homebrew-tap/releases/tag/cypari2-2.2.6) — Python interface to PARI/GP.
* [cysignals](Formula/c/cysignals.rb) [1.13.1](https://github.com/dimpase/homebrew-tap/releases/tag/cysignals-1.13.1) — Signal handling for Cython.
* [gmpy2](Formula/g/gmpy2.rb) [2.3.1](https://github.com/dimpase/homebrew-tap/releases/tag/gmpy2-2.3.1) — Python interface to GMP, MPFR and MPC.
* [matplotlib-accelerate](Formula/m/matplotlib-accelerate.rb) [3.11.2_2](https://github.com/dimpase/homebrew-tap/releases/tag/matplotlib-accelerate-3.11.2_2) — Matplotlib with Accelerate on macOS and OpenBLAS on Linux.
* [numpy-accelerate](Formula/n/numpy-accelerate.rb) [2.5.3](https://github.com/dimpase/homebrew-tap/releases/tag/numpy-accelerate-2.5.3) — NumPy with Apple Accelerate (macOS).
* [pillow-python313](Formula/p/pillow-python313.rb) [12.3.0](https://github.com/dimpase/homebrew-tap/releases/tag/pillow-python313-12.3.0) — Pillow for Python 3.13.
* [pplpy](Formula/p/pplpy.rb) [0.9.0](https://github.com/dimpase/homebrew-tap/releases/tag/pplpy-0.9.0) — Python interface to the Parma Polyhedra Library.
* [scipy-accelerate](Formula/s/scipy-accelerate.rb) [1.18.1](https://github.com/dimpase/homebrew-tap/releases/tag/scipy-accelerate-1.18.1) — SciPy with Apple Accelerate (macOS).

### PARI/GP and data

* [pari](Formula/p/pari.rb) [2.19.0_2](https://github.com/dimpase/homebrew-tap/releases/tag/pari-2.19.0_2) — Number theory and computer algebra.
* [pari-elldata](Formula/p/pari-elldata.rb) [20210301](https://github.com/dimpase/homebrew-tap/releases/tag/pari-elldata-20210301) — Cremona elliptic curve data.
* [pari-galdata](Formula/p/pari-galdata.rb) [20080411](https://github.com/dimpase/homebrew-tap/releases/tag/pari-galdata-20080411) — Galois resolvents.
* [pari-galpol](Formula/p/pari-galpol.rb) [20180625](https://github.com/dimpase/homebrew-tap/releases/tag/pari-galpol-20180625) — Galois polynomial database.
* [pari-seadata](Formula/p/pari-seadata.rb) [20090618](https://github.com/dimpase/homebrew-tap/releases/tag/pari-seadata-20090618) — Modular polynomials.

### Other mathematical software and libraries

* [bliss](Formula/b/bliss.rb) [0.77](https://github.com/dimpase/homebrew-tap/releases/tag/bliss-0.77) — Graph automorphisms and canonical forms.
* [brial](Formula/b/brial.rb) [1.2.15_3](https://github.com/dimpase/homebrew-tap/releases/tag/brial-1.2.15_3) — Boolean polynomial algebra, formerly PolyBoRi.
* [cliquer](Formula/c/cliquer.rb) [1.23](https://github.com/dimpase/homebrew-tap/releases/tag/cliquer-1.23) — Weighted clique searching.
* [coxeter3](Formula/c/coxeter3.rb) [3.1](https://github.com/dimpase/homebrew-tap/releases/tag/coxeter3-3.1) — Coxeter groups.
* [eclib](Formula/e/eclib.rb) [20250627_2](https://github.com/dimpase/homebrew-tap/releases/tag/eclib-20250627_2) — Elliptic curves over Q; mwrank/libec.
* [gf2x](Formula/g/gf2x.rb) [1.3.0](https://github.com/dimpase/homebrew-tap/releases/tag/gf2x-1.3.0) — Polynomial arithmetic over GF(2).
* [gmp-ecm](Formula/e/gmp-ecm.rb) [7.0.7](https://github.com/dimpase/homebrew-tap/releases/tag/gmp-ecm-7.0.7) — Elliptic curve factorization, with OpenMP.
* [iml](Formula/i/iml.rb) [1.0.5](https://github.com/dimpase/homebrew-tap/releases/tag/iml-1.0.5) — Exact integer linear algebra.
* [kenzo](Formula/k/kenzo.rb) [1.1.10](https://github.com/dimpase/homebrew-tap/releases/tag/kenzo-1.1.10) — Topology and homology, as an ECL module.
* [lcalc](Formula/l/lcalc.rb) [2.2.2_1](https://github.com/dimpase/homebrew-tap/releases/tag/lcalc-2.2.2_1) — L-functions.
* [libbraiding](Formula/l/libbraiding.rb) [1.3.2](https://github.com/dimpase/homebrew-tap/releases/tag/libbraiding-1.3.2) — Braid computations.
* [libhomfly](Formula/l/libhomfly.rb) [1.04](https://github.com/dimpase/homebrew-tap/releases/tag/libhomfly-1.04) — HOMFLY polynomials of knots and links.
* [lrcalc](Formula/l/lrcalc.rb) [2.1](https://github.com/dimpase/homebrew-tap/releases/tag/lrcalc-2.1) — Littlewood–Richardson coefficients.
* [m4ri](Formula/m/m4ri.rb) [20260122](https://github.com/dimpase/homebrew-tap/releases/tag/m4ri-20260122) — Dense matrices over GF(2), with OpenMP.
* [m4rie](Formula/m/m4rie.rb) [20250128](https://github.com/dimpase/homebrew-tap/releases/tag/m4rie-20250128) — Dense matrices over GF(2^e), using the tap’s M4RI.
* [maxima-ecl](Formula/m/maxima-ecl.rb) [5.49.0_2](https://github.com/dimpase/homebrew-tap/releases/tag/maxima-ecl-5.49.0_2) — Maxima compiled with ECL.
* [mcqd](Formula/m/mcqd.rb) [1.0.2](https://github.com/dimpase/homebrew-tap/releases/tag/mcqd-1.0.2) — Maximum clique computations.
* [meataxe](Formula/m/meataxe.rb) [1.0.2_1](https://github.com/dimpase/homebrew-tap/releases/tag/meataxe-1.0.2_1) — Modular representations, with precomputed field tables.
* [planarity](Formula/p/planarity.rb) [4.0.1.0](https://github.com/dimpase/homebrew-tap/releases/tag/planarity-4.0.1.0) — Graph planarity testing and embedding.
* [rw](Formula/r/rw.rb) [0.10](https://github.com/dimpase/homebrew-tap/releases/tag/rw-0.10) — Rank-width and rank-decompositions.
* [sirocco](Formula/s/sirocco.rb) [2.1.1](https://github.com/dimpase/homebrew-tap/releases/tag/sirocco-2.1.1) — Certified root continuation.
* [symmetrica](Formula/s/symmetrica.rb) [3.1.0](https://github.com/dimpase/homebrew-tap/releases/tag/symmetrica-3.1.0) — Representation theory.
* [sympow](Formula/s/sympow.rb) [2.023.7_1](https://github.com/dimpase/homebrew-tap/releases/tag/sympow-2.023.7_1) — Symmetric-power elliptic curve L-functions.
* [tachyon](Formula/t/tachyon.rb) [0.99.5.upstream](https://github.com/dimpase/homebrew-tap/releases/tag/tachyon-0.99.5.upstream) — Ray tracing.
* [treedec](Formula/t/treedec.rb) [0.9.3](https://github.com/dimpase/homebrew-tap/releases/tag/treedec-0.9.3) — Tree decompositions; Sage’s tdlib package.

SageMath and `sagemath-deps` use Homebrew core’s `m4ri` and `m4rie`, including
through BRiAl. The tap variants above are separate alternatives.

For standalone Maxima plotting, install Gnuplot separately with
`brew install gnuplot`. Sage’s Matplotlib plotting does not require it.

### Disabled formula

[ecl-fork](Formula/e/ecl-fork.rb) was disabled on 2026-07-01; use Homebrew core’s
`ecl`. Its [26.5.5 bottles](https://github.com/dimpase/homebrew-tap/releases/tag/ecl-fork-26.5.5)
remain available as historical releases.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
