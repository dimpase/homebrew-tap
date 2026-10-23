class Meataxe < Formula
  desc "Set of programs for computing with modular representations"
  homepage "https://github.com/simon-king-jena/SharedMeatAxe"
  url "https://github.com/simon-king-jena/SharedMeatAxe/releases/download/v1.0.3/shared_meataxe-1.0.3.tar.bz2"
  sha256 "3b2fe10d44379e8bc749e586449dfa0ccf993bbd30490d64a99645ca4884c4c3"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/meataxe-1.0.3"
    sha256 arm64_tahoe:  "0fffcf881218e8e9142e0daabbb59708a53049bfd7524ab95e7c3dcb4622a65f"
    sha256 arm64_linux:  "526482cdcf3f3f80897cd35457d816326805a74d1361321ad70f44ce65023729"
    sha256 x86_64_linux: "d87ff617962cb93726e7ac42a4aa1f7f1cdf7337f399d8682ef87f8d73106c5f"
  end

  depends_on "libtool" => :build

  def install
    ENV.append "CFLAGS", "-DMTXBIN=\\\"#{bin}\\\""
    system "./configure", "--enable-tables", "--with-mtxlib=#{pkgshare}", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    assert_path_exists pkgshare/"p256.zzz"
    (testpath/"input.txt").write <<~EOS
      matrix field=256 rows=1 cols=1
      1
    EOS
    system bin/"zcv", "input.txt", "matrix"
    assert_equal "matrix field=256 rows=1 cols=1 1", shell_output("#{bin}/zpr matrix").split.join(" ")
  end
end
