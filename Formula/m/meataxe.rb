class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.2/shared_meataxe-1.0.2.tar.bz2"
  sha256 "c2e2ec85cdbcde5800d7b0577937afcc86f4a7610ae4d86614428445deb301e8"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/meataxe-1.0.2_1"
    sha256 arm64_tahoe:  "60bcee02cad34f0f3500365c4319476950146759c6fc72bfe3826fcd46157401"
    sha256 arm64_linux:  "e7d05a36d7fc1f436130d29d1437cace03c38a4639f411dc16468a5ba5262b65"
    sha256 x86_64_linux: "afda5e900dd8459e7c811c2c5d2f9a9e5281ee437930a173a8e61874f6452ae8"
  end

  depends_on "dimpase/tap/pari" => :build
  depends_on "libtool" => :build

  def install
    ENV.append "CFLAGS", "-DMTXLIB=\\\"#{lib}\\\" -DMTXBIN=\\\"#{bin}\\\""
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
    primes = `echo '[n | n <- [2..255], isprimepower(n)]' | gp -qf`
    require "json"
    JSON.parse(primes).each do |i|
      (buildpath/"inp.txt").write <<~EOS
        matrix field=#{i} rows=0 cols=0
      EOS
      system "#{bin}/zcv", "inp.txt", File::NULL
      File.delete("inp.txt")
    end
    lib.install Dir["*.zzz"]
  end

  test do
    system "true"
  end
end
