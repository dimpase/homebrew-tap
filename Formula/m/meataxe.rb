class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.2/shared_meataxe-1.0.2.tar.bz2"
  sha256 "c2e2ec85cdbcde5800d7b0577937afcc86f4a7610ae4d86614428445deb301e8"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/meataxe-1.0.2"
    rebuild 1
    sha256 arm64_tahoe:  "f328ebf53c77fad8da668c17beb7a29476932118d82ad92898c38643225ae589"
    sha256 sequoia:      "6c92260cee82e09517d5c922fc22449529a5a6d082d43aa4cf2768027f99ef8f"
    sha256 x86_64_linux: "e978ae2098f1fafa231c2a591955455310e190a2c9f0b90f3dfdf021294d8edc"
  end

  depends_on "libtool" => :build
  depends_on "pari" => :build

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
