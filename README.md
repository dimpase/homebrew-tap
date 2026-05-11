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
* ecl-fork  (version 26.5.5) - not needed, as Homebrew now has one
* gf2x      (no tuning)
* gmp-ecm   (for `ecm` the elliptic curve factorisation algorithm)
* iml
* lcalc
* libhomfly 
* m4ri
* m4rie
* maxima-ecl (installs maxima.fas into `$(brew --prefix)/lib/ecl/`)
* meataxe
* planarity
* rw
* sirocco
* symmetrica

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
