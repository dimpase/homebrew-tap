class PariElldata < Formula
  desc "J.E. Cremona elliptic curve data for PARI/GP"
  homepage "https://pari.math.u-bordeaux.fr/packages.html"
  url "https://pari.math.u-bordeaux.fr/pub/pari/packages/elldata.tgz"
  # Refer to https://pari.math.u-bordeaux.fr/packages.html#packages for most recent package date
  version "20210301"
  sha256 "dd551e64932d4ab27b3f2b2d1da871c2353672fc1a74705c52e3c0de84bd0cf6"
  license "GPL-2.0-or-later"

  # The only difference in the `livecheck` blocks for pari-* formulae is the
  # package name in the regex and they should otherwise be kept in parity.
  livecheck do
    url :homepage
    regex(%r{>\s*elldata\.t[^<]+?</a>(?:[&(.;\s\w]+?(?:\),?|,))?\s*([a-z]+\s+\d{1,2},?\s+\d{4})\D}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| Date.parse(match.first)&.strftime("%Y%m%d") }
    end
  end

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/pari-elldata-20210301"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "e24080d56bda00d8557c633ff8c5fdd5eb4f68c1dc7e36fc2346c7ffd8916603"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "d3fcea74c7695f263c0530d730ce42331e75c1a784e8c21d8b7bfac1a4b11117"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1b3e8a5abb4c871eab3d513ec01204f7910e19594079913f49b0d0a0e6491aaf"
  end

  depends_on "dimpase/tap/pari"

  def install
    (share/"pari/elldata").install Utils::Gzip.compress(*Dir["#{buildpath}/elldata/ell*"])
    doc.install "elldata/README"
  end

  test do
    expected_output = "[0, -1, 1, -10, -20, -4, -20, -79, -21, 496, 20008, -161051, -122023936/161051, " \
                      "Vecsmall([1]), [Vecsmall([128, -1])], [0, 0, 0, 0, 0, 0, 0, 0]]"
    output = pipe_output("#{formula_opt_bin("dimpase/tap/pari")}/gp -q", "ellinit(\"11a1\")").chomp
    assert_equal expected_output, output
  end
end
