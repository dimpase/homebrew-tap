class PariGaldata < Formula
  desc "Galois resolvents data for PARI/GP"
  homepage "https://pari.math.u-bordeaux.fr/packages.html"
  url "https://pari.math.u-bordeaux.fr/pub/pari/packages/galdata.tgz"
  # Refer to https://pari.math.u-bordeaux.fr/packages.html#packages for most recent package date
  version "20080411"
  sha256 "b7c1650099b24a20bdade47a85a928351c586287f0d4c73933313873e63290dd"
  license "GPL-2.0-or-later"

  # The only difference in the `livecheck` blocks for pari-* formulae is the
  # package name in the regex and they should otherwise be kept in parity.
  livecheck do
    url :homepage
    regex(%r{>\s*galdata\.t[^<]+?</a>(?:[&(.;\s\w]+?(?:\),?|,))?\s*([a-z]+\s+\d{1,2},?\s+\d{4})\D}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| Date.parse(match.first)&.strftime("%Y%m%d") }
    end
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-galdata-20080411"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "7a51cfa71949fd12253fbef873ef8ce3a16d94e771445dc123a79c3f336d5654"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "d5aa4b611376d426914ae1b50385379fbf082eb2f70490a9d3c56ecbfe0d313a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "58cd19f872b12ca6d8c6dcc6dd9ae0eefcb5fbc8f7b54794ab704f05e7818277"
  end

  depends_on "dimpase/tap/pari"

  def install
    (share/"pari/galdata").install Utils::Gzip.compress(*Dir["#{buildpath}/galdata/*"])
  end

  test do
    expected_output = "[16, -1, 8, \"2D_8(8)=[D(4)]2\"]"
    output = pipe_output("#{formula_opt_bin("dimpase/tap/pari")}/gp -q", "polgalois(x^8-2)").chomp
    assert_equal expected_output, output
  end
end
