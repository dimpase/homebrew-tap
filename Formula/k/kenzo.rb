class Kenzo < Formula
  desc "Construct topological spaces and compute homology groups"
  homepage "https://github.com/gheber/kenzo"
  url "https://github.com/miguelmarco/kenzo/releases/download/1.1.10/kenzo-1.1.10.tar.gz"
  sha256 "2a23697611a37714433a9e273098d0b2dfe4fdcd83d98b9fc8d7a055c064ed6b"
  license "GPL-2.0-or-later"

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
