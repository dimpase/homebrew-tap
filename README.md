# Dimpase's Tap

## How do I install these formulae?

`brew install dimpase/tap/<formula>`

Or `brew tap dimpase/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "dimpase/tap"
brew "<formula>"
```


Currently implemented taps

* bliss
* brial
* cliquer
* coxeter3
* ~ecl-fork~  (version 26.5.5) - not needed, as Homebrew now has one
* eclib     (a.k.a. mwrank/libec)
* gf2x      (no tuning)
* ~gmp-ecm~   (for `ecm` the elliptic curve factorisation algorithm) - now in mainline homebrew
* iml
* lcalc
* libbraiding
* libhomfly 
* ~m4ri~ upstreamed to mainline homebrew, only use this one if you need OpenMP support
* ~m4rie~ upstreamed to mainline homebrew
* maxima-ecl (installs maxima.fas into `$(brew --prefix)/lib/ecl/`)
* meataxe
* planarity
* rw
* sirocco
* symmetrica
* treedec    (Sage spkg tdlib, differently named due to a name clash with a Homebrew package)

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
