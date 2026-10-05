class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.2/shared_meataxe-1.0.2.tar.bz2"
  sha256 "c2e2ec85cdbcde5800d7b0577937afcc86f4a7610ae4d86614428445deb301e8"
  license "GPL-2.0-or-later"
  revision 1

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
