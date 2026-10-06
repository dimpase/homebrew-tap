class PariSeadata < Formula
  desc "Modular polynomial data for PARI/GP"
  homepage "https://pari.math.u-bordeaux.fr/packages.html"
  url "https://pari.math.u-bordeaux.fr/pub/pari/packages/seadata.tgz"
  # Refer to https://pari.math.u-bordeaux.fr/packages.html#packages for most recent package date
  version "20090618"
  sha256 "c9282a525ea3f92c1f9c6c69e37ac5a87b48fb9ccd943cfd7c881a3851195833"
  license "GPL-2.0-or-later"

  # The only difference in the `livecheck` blocks for pari-* formulae is the
  # package name in the regex and they should otherwise be kept in parity.
  livecheck do
    url :homepage
    regex(%r{>\s*seadata\.t[^<]+?</a>(?:[&(.;\s\w]+?(?:\),?|,))?\s*([a-z]+\s+\d{1,2},?\s+\d{4})\D}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| Date.parse(match.first)&.strftime("%Y%m%d") }
    end
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-seadata-20090618"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c200692e9e44267659a059380c00dbafe2b31fa1e3da0eb43a589b2eec7cc1f9"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "cb979f5111f5e163559e77a2a14b7035ba8f9aaadd37f39411927dd0b33e7548"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dac9486b3c4bae5211c5fb9d5f4d83a128d8a1e1b51caad2bba66952de56384a"
  end

  depends_on "dimpase/tap/pari"

  def install
    (share/"pari/seadata").install Utils::Gzip.compress(*Dir["#{buildpath}/seadata/sea*"])
    doc.install "seadata/README"
  end

  test do
    expected_output = "[x^4 + 36*x^3 + 270*x^2 + (-y + 756)*x + 729, 0]"
    output = pipe_output("#{formula_opt_bin("dimpase/tap/pari")}/gp -q", "ellmodulareqn(3)").chomp
    assert_equal expected_output, output
  end
end
