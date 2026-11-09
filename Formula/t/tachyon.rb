class Tachyon < Formula
  desc "John Stone's ray tracer"
  homepage "https://en.wikipedia.org/wiki/Tachyon_(software)"
  url "https://github.com/dimpase/homebrew-tap/releases/download/tachyon-0.99.5/tachyon-0.99.5.upstream.tar.gz"
  sha256 "20743a6897895e359f5dcef23f8026bb10d507bbca78b7a7e54b4e027db93d94"
  # homepage "http://jedi.ks.uiuc.edu/~johns/raytracer/"
  # url "http://jedi.ks.uiuc.edu/~johns/raytracer/files/0.99.5/tachyon-0.99.5.tar.gz"
  # sha256 "09203c102311149f5df5cc367409f96c725742666d19c24db5ba994d5a81a6f5"
  license "BSD-3-clause"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/tachyon-0.99.5.upstream"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "1fa115a4d3b06ef0bbc578e9c42afe6e787c46ea6861308cc52532da3525eeb8"
    sha256 cellar: :any, arm64_linux:  "c07ebd877638c8f9e2727603b5fa7af0c5401c5f22d03e921f456a6f9ee36d1d"
    sha256 cellar: :any, x86_64_linux: "c036dacc50c9f82173f5355bbcb446c99df65f13595c99844ea1be868093ee4a"
  end

  depends_on "libpng"

  def install
    libpng = Formula["libpng"]
    os = if OS.mac?
      "macosx"
    else
      "linux-thr"
    end
    chdir "unix" do
      system "make", os.to_s, "USEPNG=-DUSEPNG",
        "PNGINC=-I#{libpng.opt_include}",
        "PNGLIB=-L#{libpng.opt_lib} -lpng"
    end
    ohai "Now installing the tachyon binary into bin/"
    bin.install "compile/#{os}/tachyon"
  end

  test do
    (testpath/"test.input").write <<~INP
      BEGIN_SCENE
        RESOLUTION 500 500

        CAMERA
          ZOOM 1.0
          ASPECTRATIO 1.0
          ANTIALIASING 4
          RAYDEPTH 5
          CENTER 0.0 0.0 -5.0
          VIEWDIR 0.0 0.0 1.0
          UPDIR 0.0 1.0 0.0
        END_CAMERA

        TEXDEF sample_texture
          AMBIENT 0.2
          DIFFUSE 0.8
          SPECULAR 0.3
          OPACITY 1.0
          COLOR 1.0 0.0 0.0
          TEXFUNC 0

        LIGHT CENTER 2.0 4.0 -6.0 RAD 0.05 COLOR 1.0 1.0 1.0
        SPHERE CENTER 0.0 0.0 0.0 RAD 1.5 sample_texture
      END_SCENE
    INP
    assert_match "Scene contains 2 objects.",
      shell_output("#{bin}/tachyon #{testpath}/test.input")
  end
end
