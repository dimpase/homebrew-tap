class PariGalpol < Formula
  desc "Galois polynomial database for PARI/GP"
  homepage "https://pari.math.u-bordeaux.fr/packages.html"
  url "https://pari.math.u-bordeaux.fr/pub/pari/packages/galpol.tgz"
  # Refer to https://pari.math.u-bordeaux.fr/packages.html#packages for most recent package date
  version "20180625"
  sha256 "562af28316ee335ee38c1172c2d5ecccb79f55c368fb9f2c6f40fc0f416bb01b"
  license "GPL-2.0-or-later"

  # The only difference in the `livecheck` blocks for pari-* formulae is the
  # package name in the regex and they should otherwise be kept in parity.
  livecheck do
    url :homepage
    regex(%r{>\s*galpol\.t[^<]+?</a>(?:[&(.;\s\w]+?(?:\),?|,))?\s*([a-z]+\s+\d{1,2},?\s+\d{4})\D}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| Date.parse(match.first)&.strftime("%Y%m%d") }
    end
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-galpol-20180625"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c9cbb0aa241e08ddff82eae987581554cb2b8521aa2a691f3c6bb6537e200c63"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "855db35fff4b7c1d888d68b57f9629be28720fbd08ea1e6f9a348fc9ff241950"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c1fc16555343ff12627289f2e146a900fc44e26055e3a5a4916f6731c851e172"
  end

  depends_on "dimpase/tap/pari"

  def install
    Dir.glob("galpol/*/**/*").each do |path|
      Utils::Gzip.compress(path) unless File.directory?(path)
    end

    (share/"pari/galpol").install Dir["galpol/*/"]
    doc.install "galpol/README"
  end

  test do
    assert_equal "5", pipe_output("#{formula_opt_bin("dimpase/tap/pari")}/gp -q", "galoisgetpol(8)").chomp
    assert_equal "\"C3 : C4\"",
pipe_output("#{formula_opt_bin("dimpase/tap/pari")}/gp -q", "galoisgetname(12,1)").chomp
  end
end
