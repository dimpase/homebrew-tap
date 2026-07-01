class Kenzo < Formula
  desc "Construct topological spaces and compute homology groups"
  homepage "https://github.com/gheber/kenzo"
  url "https://github.com/miguelmarco/kenzo/releases/download/1.1.10/kenzo-1.1.10.tar.gz"
  sha256 "2a23697611a37714433a9e273098d0b2dfe4fdcd83d98b9fc8d7a055c064ed6b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/kenzo-1.1.10"
    sha256 cellar: :any, arm64_tahoe:  "1668e9826a2f71f0864cf9d096c8aecc2ca000f791434db76dc1fac250b2c7d5"
    sha256               x86_64_linux: "6a6fce746852aaa1ee25e39f88b4a5d0ab95382761d3419f478406d59378d8c3"
  end

  depends_on "bdw-gc"
  depends_on "ecl"
  depends_on "gmp"

  def install
    ohai "Compiling kenzo"
    system "ecl < compile.lisp"
    require "fileutils"
    ohai "Installing kenzo.fas into #{lib}/ecl-#{Formula["ecl"].version}"
    File.rename "kenzo--all-systems.fasb", "kenzo.fas"
    chmod 0444, "kenzo.fas", verbose: true
    (lib/"ecl-#{Formula["ecl"].version}").install "kenzo.fas"
  end

  test do
    (testpath/"tst.lsp").write <<~LSP
      (require :kenzo)
      (quit)
    LSP
    system "ecl < tst.lsp"
  end
end
