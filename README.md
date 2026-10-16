# Dimpase's Tap

## How do I install these formulae?

`brew install dimpase/tap/<formula>`

Or `brew tap dimpase/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "dimpase/tap"
brew "<formula>"
```


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

Currently implemented taps

* bliss
* brial
* cliquer
* coxeter3
* ~ecl-fork~  (version 26.5.5) - not needed, as Homebrew now has one. Disabled 2026-07-01.
* eclib     (a.k.a. mwrank/libec)
* gf2x      (no tuning)
* ~gmp-ecm~   (for `ecm` the elliptic curve factorisation algorithm) - now in mainline homebrew
* iml
* kenzo (installs kenzo.fas into `$(brew --prefix)/lib/ecl-<version>/`) 
   - ~currently `ecl` does not see it, so one has to manually link it:~
   *no longer needed*.
   - Reinstall fixed `ecl` and `kenzo` by doing `brew reinstall ecl` and `brew reinstall dimpase/tap/kenzo`
* lcalc
* libbraiding
* libhomfly
* lrcalc
* ~m4ri~ upstreamed to mainline homebrew, only use this one if you need OpenMP support
* ~m4rie~ upstreamed to mainline homebrew
* maxima-ecl (installs maxima.fas into `$(brew --prefix)/lib/ecl-<version>/`) 
   - ~currently `ecl` does not see it, so one has to manually link it:~
  *no longer needed*.
   - Reinstall fixed `ecl` and `maxima-ecl` by doing `brew reinstall ecl` and `brew reinstall dimpase/tap/maxima-ecl`
* mcqd (which can be found by `cmake` now)
* meataxe (beware of https://github.com/dimpase/homebrew-tap/issues/48 - as a temporary workaround do `export MTXLIB=/tmp` or something like this)
* planarity
* rw
* sirocco
* symmetrica
* sympow
* tachyon
* treedec    (Sage spkg tdlib, differently named due to a name clash with a Homebrew package)

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
