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
    sha256 cellar: :any, arm64_tahoe:  "3d731bbbbaa0d44ce187413d22b028e4f5853af6f1d8b1d91b5abbaee547bf03"
    sha256 cellar: :any, x86_64_linux: "5ca83cb3361f69310eeba93136cb8101cc72d540abf3147e4690a0c1e46f2cee"
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
      shell_output("#{bin}/tachyon  #{testpath}/test.input | grep '2 objects'")
  end
end
