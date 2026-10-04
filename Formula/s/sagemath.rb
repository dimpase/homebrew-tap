class Sagemath < Formula
  desc "Open source mathematics software"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta1.tar.gz"
  sha256 "fc3e2af93024456c3898243a49dcfa721292b85f264c4c3a94c2ed22d3385091"
  license "GPL-2.0-or-later"

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "bdw-gc"
  depends_on "boost"
  depends_on "cddlib"
  depends_on "dimpase/gap/gap"
  depends_on "dimpase/tap/bliss"
  depends_on "dimpase/tap/brial"
  depends_on "dimpase/tap/cliquer"
  depends_on "dimpase/tap/coxeter3"
  depends_on "dimpase/tap/eclib"
  depends_on "dimpase/tap/gmp-ecm"
  depends_on "dimpase/tap/iml"
  depends_on "dimpase/tap/lcalc"
  depends_on "dimpase/tap/libbraiding"
  depends_on "dimpase/tap/libhomfly"
  depends_on "dimpase/tap/lrcalc"
  depends_on "dimpase/tap/m4ri"
  depends_on "dimpase/tap/m4rie"
  depends_on "dimpase/tap/maxima-ecl"
  depends_on "dimpase/tap/mcqd"
  depends_on "dimpase/tap/meataxe"
  depends_on "pari"
  depends_on "dimpase/tap/planarity"
  depends_on "dimpase/tap/rw"
  depends_on "dimpase/tap/sirocco"
  depends_on "dimpase/tap/symmetrica"
  depends_on "dimpase/tap/sympow"
  depends_on "dimpase/tap/tachyon"
  depends_on "dimpase/tap/treedec"
  depends_on "ecl"
  depends_on "flint"
  depends_on "fplll"
  depends_on "freetype"
  depends_on "gcc"
  depends_on "gd"
  depends_on "glpk"
  depends_on "gmp"
  depends_on "gsl"
  depends_on "highs"
  depends_on "jpeg-turbo"
  depends_on "libmpc"
  depends_on "libpng"
  depends_on "libraqm"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "macaulay2/tap/fflas-ffpack"
  depends_on "macaulay2/tap/gfan"
  depends_on "macaulay2/tap/givaro"
  depends_on "macaulay2/tap/linbox"
  depends_on "macaulay2/tap/normaliz"
  depends_on "macaulay2/tap/palp"
  depends_on "mpfi"
  depends_on "mpfr"
  depends_on "nauty"
  depends_on "ntl"
  depends_on "numpy"
  depends_on "pari-elldata"
  depends_on "pari-galdata"
  depends_on "pari-galpol"
  depends_on "pari-seadata"
  depends_on "ppl"
  depends_on "primecount"
  depends_on "python@3.13"
  depends_on "python@3.14"
  depends_on "qhull"
  depends_on "scipy"
  depends_on "singular"
  depends_on "webp"
  depends_on "zeromq"
  depends_on "zlib"

  on_linux do
    depends_on "binutils" => :build
    depends_on "patchelf" => :build
    depends_on "openblas"
  end

  pypi_packages package_name:     "sagemath",
                extra_packages:   %w[
                  cysignals cython gmpy2 jinja2 memory-allocator meson-python packaging
                  pybind11 pyproject-metadata sagemath-data-elliptic-curves sagemath-data-graphs
                  sagemath-data-polytopes setuptools wheel
                ],
                exclude_packages: %w[cypari2 meson numpy scipy]

  # This Git version supports the PARI 2.19 supplied by Homebrew.
  resource "cypari2" do
    url "https://github.com/sagemath/cypari2/archive/b1efda3cb92810222c71bf62b51e59a9f57b80a7.tar.gz"
    version "2.2.6"
    sha256 "d520440948b62d963127df1dcef0118de294d70668604a38931f08b0702ba8df"

    livecheck do
      skip "Pinned Git version for PARI 2.19 compatibility"
    end
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/6d/44/f5da03a8ef95d369145c5bb53050e7877c9f3d312e128605fd9504829143/setuptools-84.0.0.tar.gz"
    sha256 "f4695c21257f0d9b537ec2692c941d02ee143b7cc1276941349a546573b2ef73"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
    sha256 "94edc256424af38762eb31306eed28beb9f0efc50a8837492c9d6fd6004aed79"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/d0/20/50ed6bdf27dec98b568a8ae25dc599f35baa3d9709f9e83fd1edb56b9a90/wheel-0.48.0.tar.gz"
    sha256 "94800765601e9171bf5d58d066e640662842bcedcbab982b2c90787a2c987322"
  end

  resource "pyproject-metadata" do
    url "https://files.pythonhosted.org/packages/4f/76/1cae539918a7b1746d624c2f01560b793c22cd8c081157505bb9bbf0e34d/pyproject_metadata-0.12.1.tar.gz"
    sha256 "8809a4df6fe08279b39a8890669506ed3158e0617855ac9aff098fcbe772ae4c"
  end

  resource "meson-python" do
    url "https://files.pythonhosted.org/packages/b4/40/343ae23722d5d66a7b94b752d1b194202640995296379333b274b1860871/meson_python-0.22.1.tar.gz"
    sha256 "52c88628b0e5671592dc2306613fb5f6f3615fd24def059b9894f143b7f9a139"
  end

  resource "cython" do
    url "https://files.pythonhosted.org/packages/a9/d8/4981ef716ad0e3ff0d3ef383aefc6b03c4a88dee33b272bf8e0d833001ca/cython-3.3.0.tar.gz"
    sha256 "eed0d93fbca7087f143b42c34b05a825849bdf17f101572c2105acfa49aa88b8"
  end

  resource "gmpy2" do
    url "https://files.pythonhosted.org/packages/03/47/5c59682cd4d94291382f447dbe1f6229c8b8a144aa85d32d38ecaf8cfb73/gmpy2-2.3.1.tar.gz"
    sha256 "313f35e9fe6b9ddf72759b14dac25166fe5757c970403e4bbf87a70ab2be07df"
  end

  resource "memory-allocator" do
    url "https://files.pythonhosted.org/packages/09/a9/2a966afb82df71f759e0c46cef0dc46d1f535897c6b341fafb2bd5e08b29/memory_allocator-0.2.0.tar.gz"
    sha256 "675d3c91019db98c97441de73d5c648821e5ae813f3f54cd09863d474b48fe26"
  end

  resource "cysignals" do
    url "https://files.pythonhosted.org/packages/98/dd/9157e0e6138e395405c7ef56a55b0edcc292e2a9e7f8c90e8b2d912e9a1d/cysignals-1.13.1.tar.gz"
    sha256 "6444b86ddd1f31c7b15e4f0a3dafb973507759676a00f2cc599f0d75062d9eb0"
  end

  resource "alabaster" do
    url "https://files.pythonhosted.org/packages/a6/f8/d9c74d0daf3f742840fd818d69cfae176fa332022fd44e3469487d5a9420/alabaster-1.0.0.tar.gz"
    sha256 "c00dca57bca26fa62a6d7d0a9fcce65f3e026e9bfe33e9c538fd3fbb2144fd9e"
  end

  resource "asttokens" do
    url "https://files.pythonhosted.org/packages/25/1e/faf0f247f6f881b98fc4d6d07e14085cb89d13665084e6d6ac1dc2c03d0b/asttokens-3.0.2.tar.gz"
    sha256 "3ecdbd8f2cc195f53ccada3a613538bb5f9ef6f6869129f13e03c30a677b8fe2"
  end

  resource "babel" do
    url "https://files.pythonhosted.org/packages/7d/b2/51899539b6ceeeb420d40ed3cd4b7a40519404f9baf3d4ac99dc413a834b/babel-2.18.0.tar.gz"
    sha256 "b80b99a14bd085fcacfa15c9165f651fbb3406e66cc603abf11c5750937c992d"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/a3/c2/24167ea9858356b47a87a50d39908bfdb72ceeefe0041586e704e5376b3a/certifi-2026.7.22.tar.gz"
    sha256 "741e2c3b351ddf169a738da9f2c048608ff7f2c5cc02f1ebc6b118bb090d5d55"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/33/1c/f41d4e74c28ab327ff3acd36053f7ea506c55872d7a90b0fa71aa3ab0c89/charset_normalizer-3.5.2.tar.gz"
    sha256 "39de2a259fc954455c57274dc94c79d5842774e1247a016aff30bc0efed0f4ef"
  end

  resource "comm" do
    url "https://files.pythonhosted.org/packages/4c/13/7d740c5849255756bc17888787313b61fd38a0a8304fc4f073dfc46122aa/comm-0.2.3.tar.gz"
    sha256 "2dc8048c10962d55d7ad693be1e7045d891b7ce8d999c97963a5e3e99c055971"
  end

  resource "contourpy" do
    url "https://files.pythonhosted.org/packages/83/5a/a55177dd22553a277388e8a1b3220e92de91bacb28356cdc73caa240121d/contourpy-1.4.0.tar.gz"
    sha256 "20156f5a1ac4f8ce02656e39a61e82164a3d359796dc8026f75b062783d500e1"
  end

  resource "conway-polynomials" do
    url "https://files.pythonhosted.org/packages/a4/73/2601b755e76fa1d90f19541d80d43b97bfa1d5c9bc284e79c8f8180ba317/conway_polynomials-0.10.tar.gz"
    sha256 "4f619f64f81a3eb16c4e26c5a284feeec27a6f4aad647643e79af289801ae0f3"
  end

  resource "cycler" do
    url "https://files.pythonhosted.org/packages/a9/95/a3dbbb5028f35eafb79008e7522a75244477d2838f38cbb722248dabc2a8/cycler-0.12.1.tar.gz"
    sha256 "88bb128f02ba341da8ef447245a9e138fae777f6a23943da4540077d3601eb1c"
  end

  resource "debugpy" do
    url "https://files.pythonhosted.org/packages/44/9d/3cb6693342acf96802dba89934a5b8da43c201d764ebd1f2c0514a3d42bd/debugpy-1.8.22.tar.gz"
    sha256 "e489c7268e1c7b41e13b438d9c533d2a7af73fb59bf8cd30fead8286c1c39c4e"
  end

  resource "docutils" do
    url "https://files.pythonhosted.org/packages/ae/b6/03bb70946330e88ffec97aefd3ea75ba575cb2e762061e0e62a213befee8/docutils-0.22.4.tar.gz"
    sha256 "4db53b1fde9abecbb74d91230d32ab626d94f6badfc575d6db9194a49df29968"
  end

  resource "executing" do
    url "https://files.pythonhosted.org/packages/cc/28/c14e053b6762b1044f34a13aab6859bbf40456d37d23aa286ac24cfd9a5d/executing-2.2.1.tar.gz"
    sha256 "3632cc370565f6648cc328b32435bd120a1e4ebb20c77e3fdde9a13cd1e533c4"
  end

  resource "fonttools" do
    url "https://files.pythonhosted.org/packages/87/b6/126c659ab7e0e03e01a5f5d223abf7b2c0691ae92718085a212a3924a2a3/fonttools-4.66.1.tar.gz"
    sha256 "64967c6ddb0d4c610dfd8cb1485981b2d27972ddfb7d4bbbd9e199d2a089c450"
  end

  resource "fpylll" do
    url "https://files.pythonhosted.org/packages/6b/46/a2ee5fb35426405f76739958b16427c0cc2e06a694b8532ab7ec43ae1683/fpylll-0.6.4.tar.gz"
    sha256 "711d60d8ada46a410932cc45587728b4c7f4ea38a9b8d0be061f5ce098632ecd"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/f5/08/8eea9d4b8302028f3abb2c0813953f7aec26d33b7a8960ed760e65ff29fa/idna-3.20.tar.gz"
    sha256 "a7db850025b95ded1eae8a46181a1a6c56c92c96f0e2b005d9ff8dc0210cab44"
  end

  resource "imagesize" do
    url "https://files.pythonhosted.org/packages/fb/5e/513ff06670c84e7b9887c1fdf61b2d42b4f574a831f2f1d2222023049d8a/imagesize-2.0.1.tar.gz"
    sha256 "b2ba6a4dea487a7ebcd53248d3476aca449d30db12a2dde5e0c5ca9624fd77e5"
  end

  resource "ipykernel" do
    url "https://files.pythonhosted.org/packages/7a/05/e5499c8b762387d83926bf0389e8fff888c9bf6e7af30566a8527bc12f4a/ipykernel-7.4.0.tar.gz"
    sha256 "4330114d22b9b33575b2c7c68753fc8faabbbcfbc60b0cdff9f14dd4ce63742f"
  end

  resource "ipython" do
    url "https://files.pythonhosted.org/packages/b9/32/99451b1283ec5d92ad77073f12e1c667dc10775384d8f15c2914207149dd/ipython-9.17.1.tar.gz"
    sha256 "8919be8c27f20a6f4423145028063f6637b42a03ce57665bb12015ee1f073529"
  end

  resource "ipython-pygments-lexers" do
    url "https://files.pythonhosted.org/packages/ef/4c/5dd1d8af08107f88c7f741ead7a40854b8ac24ddf9ae850afbcf698aa552/ipython_pygments_lexers-1.1.1.tar.gz"
    sha256 "09c0138009e56b6854f9535736f4171d855c8c08a563a0dcd8022f78355c7e81"
  end

  resource "ipywidgets" do
    url "https://files.pythonhosted.org/packages/c9/7c/6db60eddf38547353b06d57941f5eee22a990640ce30479fd71a810507f2/ipywidgets-8.1.9.tar.gz"
    sha256 "bcccba38a6ec3253f7a39c943cea5b9ad01999ce071396171adbc51c6a6a8613"
  end

  resource "jedi" do
    url "https://files.pythonhosted.org/packages/46/b7/a3635f6a2d7cf5b5dd98064fc1d5fbbafcb25477bcea204a3a92145d158b/jedi-0.20.0.tar.gz"
    sha256 "c3f4ccbd276696f4b19c54618d4fb18f9fc24b0aef02acf704b23f487daa1011"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz"
    sha256 "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d"
  end

  resource "jupyter-client" do
    url "https://files.pythonhosted.org/packages/c5/2a/906772148a06e48885039e0250c340b770a55bbf37b08d6ee0449df369c3/jupyter_client-8.10.0.tar.gz"
    sha256 "9f7116294dca55f1785be880057d44544db9b1567718d92cb33c58886afb9497"
  end

  resource "jupyter-core" do
    url "https://files.pythonhosted.org/packages/02/49/9d1284d0dc65e2c757b74c6687b6d319b02f822ad039e5c512df9194d9dd/jupyter_core-5.9.1.tar.gz"
    sha256 "4d09aaff303b9566c3ce657f580bd089ff5c91f5f89cf7d8846c3cdf465b5508"
  end

  resource "jupyterlab-widgets" do
    url "https://files.pythonhosted.org/packages/21/8b/e739cf9066ad5037a2d4b0a403f06da374fdccb9748221661c8b492d3dbc/jupyterlab_widgets-3.0.17.tar.gz"
    sha256 "6e61fe21ca8a66039180a5cc52a433e07279d2fee79c8be963e00d55193f17a8"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/ba/07/bd78e6a8fae171ea041ef5bba3ed21a003522fa088834b069b1909981f30/kiwisolver-1.5.1.tar.gz"
    sha256 "f1303ef2eec81262a4b708c3e858afe58d7c75ad91c1c05266eda7673369859a"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/38/9b/e422a865e1d5d57d0e509b4e0bf1c1a70a7f6382c29a5aa428df994c8bc8/markupsafe-3.0.4.tar.gz"
    sha256 "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6"
  end

  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/e7/c8/9aa712a0afb882649424dd8de8ad9aa6235e796e84c6052e8f6dc1598d0d/matplotlib-3.11.2.tar.gz"
    sha256 "cec596316640f2b394b8f0daa0ea61a8eae82d017b620b9f202befb972a59ea4"
  end

  resource "matplotlib-inline" do
    url "https://files.pythonhosted.org/packages/bd/c0/9f7c9a46090390368a4d7bcb76bb87a4a36c421e4c0792cdb53486ffac7a/matplotlib_inline-0.2.2.tar.gz"
    sha256 "72f3fe8fce36b70d4a5b612f899090cd0401deddc4ea90e1572b9f4bfb058c79"
  end

  resource "mpmath" do
    url "https://files.pythonhosted.org/packages/e0/47/dd32fa426cc72114383ac549964eecb20ecfd886d1e5ccf5340b55b02f57/mpmath-1.3.0.tar.gz"
    sha256 "7a28eb2a9774d00c7bc92411c19a89209d5da7c4c9a9e227be8330a23a25b91f"
  end

  resource "nest-asyncio2" do
    url "https://files.pythonhosted.org/packages/5e/a6/a2775b388a14b5ea0c894bbe513c0d3e04e65e8ae583e60f5357722b8e03/nest_asyncio2-1.7.3.tar.gz"
    sha256 "2e9a84d5d1efe6d020c72988d21aec569bac42d98af2ff6b9de24640c5d22a34"
  end

  resource "networkx" do
    url "https://files.pythonhosted.org/packages/dc/76/3af777226b63a5e64a6b36b1ec5855c14e2b94a37096d4760e595fc43511/networkx-3.7.tar.gz"
    sha256 "fd77a511bd90f39f3d016351345b52cf5319b813bdca01de3f755d3cca62e96a"
  end

  resource "parso" do
    url "https://files.pythonhosted.org/packages/30/4b/90c937815137d43ce71ba043cd3566221e9df6b9c805f24b5d138c9d40a7/parso-0.8.7.tar.gz"
    sha256 "eaaac4c9fdd5e9e8852dc778d2d7405897ec510f2a298071453e5e3a07914bb1"
  end

  resource "pexpect" do
    url "https://files.pythonhosted.org/packages/42/92/cc564bf6381ff43ce1f4d06852fc19a2f11d180f23dc32d9588bee2f149d/pexpect-4.9.0.tar.gz"
    sha256 "ee7d41123f3c9911050ea2c2dac107568dc43b2d3b0c7557a33212c398ead30f"
  end

  resource "pillow" do
    url "https://files.pythonhosted.org/packages/1c/3d/bb7fca845737cf9d7dbde16ed1843984665ff2e0a518f5db43e77ec540b9/pillow-12.3.0.tar.gz"
    sha256 "3b8182a766685eaa002637e28b4ec8d6b18819a0c71f579bf0dbaa5830297cce"
  end

  resource "pkgconfig" do
    url "https://files.pythonhosted.org/packages/52/fd/0adde075cd3bfecd557bc7d757e00e231d34d8a6edb4c8d1642759254c21/pkgconfig-1.6.0.tar.gz"
    sha256 "4a5a6631ce937fafac457104a40d558785a658bbdca5c49b6295bc3fd651907f"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/17/c8/721b3855fe457da514fe249247d404b9b39c5d16532278f70ebaa6acf18b/platformdirs-4.12.2.tar.gz"
    sha256 "eab5f70271a490ef74618bb314fbb86e3c7e82fa3b9c922c2ea0e0a1a155d329"
  end

  resource "pplpy" do
    url "https://files.pythonhosted.org/packages/75/b0/bcda4d51601f4e7dc5d5983972d5947c6c2c9cb943de359f0ba989b1c7ac/pplpy-0.9.0.tar.gz"
    sha256 "8289c50d680ce3f9eacac666cb4cdbbd8a711959e7cc7cf06f7fdb4035d0cc5d"
  end

  resource "primecountpy" do
    url "https://files.pythonhosted.org/packages/82/0a/55d92a3733e41920c5e3fab2d0f2e4d265cfa17a87019a6fc756a9587037/primecountpy-0.2.1.tar.gz"
    sha256 "888706ab65cc089fb983de4639360dddc728baa4d9877a7ad8b116f645650b39"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/7d/ea/39b988c938f75cb75d7045b5c69f8bfed47ee2152c8837fb403de29d6fb8/prompt_toolkit-3.0.53.tar.gz"
    sha256 "9ec8a0ad96d5c56148b3f914aa79c1564c3fde5d2e6b876e7bc327e353cf8fa6"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  resource "ptyprocess" do
    url "https://files.pythonhosted.org/packages/20/e5/16ff212c1e452235a90aeb09066144d0c5a6a8c0834397e03f5224495c4e/ptyprocess-0.7.0.tar.gz"
    sha256 "5c5d0a3b48ceee0b48485e0c26037c0acd7d29765ca3fbb5cb3831d347423220"
  end

  resource "pure-eval" do
    url "https://files.pythonhosted.org/packages/da/9f/abfd2959e9261dd5217ca8551d4de211ca6ab26fe9b72cf44731ff6c4442/pure_eval-0.2.4.tar.gz"
    sha256 "260c2774686e651b79f8b8e7fc9d80b3599ea6a66334b47d5f4abb69fc2c0ea1"
  end

  resource "pybind11" do
    url "https://files.pythonhosted.org/packages/76/f3/95b0f40b31df41dbfe6bb0857419c9442c15839cbac4796f1c26ae0b6081/pybind11-3.1.0.tar.gz"
    sha256 "a1cc06b524ab3edca51f8ad3895f9c4fa20b8b19283173dff4ae781449dc9639"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/49/2e/ced460408999b33da6b31b0021b0f37d329e202d4169aeb164493778f25b/pygments-2.21.0.tar.gz"
    sha256 "610ca751c9bc2492b38eb9a38a7fbc93edbbb2d7182edaf34e66ae493dee5c8c"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/e4/11/b213bebff182584360cb8d17c72c1677fec5c5c228de439e63bcf8ab1c8f/pyparsing-3.3.3.tar.gz"
    sha256 "928ae7e20211f3b6f3915a72f06a0cfd29ab9d24279dd6346b6b1a7146397d36"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
    sha256 "37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
  end

  resource "pyzmq" do
    url "https://files.pythonhosted.org/packages/e7/8d/5b3d5631c2f4b4b8862f64cd0c9eb777b5710eeb5125b4be8dd0a200a4c0/pyzmq-27.2.0.tar.gz"
    sha256 "54d4259d1bfae24ecdb5ca79f7acc2eac6c286a02d6a0ae617797cb45f0726d3"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/ac/c3/e2a2b89f2d3e2179abd6d00ebd70bff6273f37fb3e0cc209f48b39d00cbf/requests-2.34.2.tar.gz"
    sha256 "f288924cae4e29463698d6d60bc6a4da69c89185ad1e0bcc4104f584e960b9ed"
  end

  resource "roman-numerals" do
    url "https://files.pythonhosted.org/packages/ae/f9/41dc953bbeb056c17d5f7a519f50fdf010bd0553be2d630bc69d1e022703/roman_numerals-4.1.0.tar.gz"
    sha256 "1af8b147eb1405d5839e78aeb93131690495fe9da5c91856cb33ad55a7f1e5b2"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
  end

  resource "snowballstemmer" do
    url "https://files.pythonhosted.org/packages/43/f8/0a71edf031f03c40db17503cb8ca78a69a171254e568e7db241b0ab57ea1/snowballstemmer-3.1.1.tar.gz"
    sha256 "e07bbc54a0d798fe6010a12398422e62a8bfbba95c394fd0956ef58cb4d3e260"
  end

  resource "sphinx" do
    url "https://files.pythonhosted.org/packages/cd/bd/f08eb0f4eed5c83f1ba2a3bd18f7745a2b1525fad70660a1c00224ec468a/sphinx-9.1.0.tar.gz"
    sha256 "7741722357dd75f8190766926071fed3bdc211c74dd2d7d4df5404da95930ddb"
  end

  resource "sphinxcontrib-applehelp" do
    url "https://files.pythonhosted.org/packages/ba/6e/b837e84a1a704953c62ef8776d45c3e8d759876b4a84fe14eba2859106fe/sphinxcontrib_applehelp-2.0.0.tar.gz"
    sha256 "2f29ef331735ce958efa4734873f084941970894c6090408b079c61b2e1c06d1"
  end

  resource "sphinxcontrib-devhelp" do
    url "https://files.pythonhosted.org/packages/f6/d2/5beee64d3e4e747f316bae86b55943f51e82bb86ecd325883ef65741e7da/sphinxcontrib_devhelp-2.0.0.tar.gz"
    sha256 "411f5d96d445d1d73bb5d52133377b4248ec79db5c793ce7dbe59e074b4dd1ad"
  end

  resource "sphinxcontrib-htmlhelp" do
    url "https://files.pythonhosted.org/packages/43/93/983afd9aa001e5201eab16b5a444ed5b9b0a7a010541e0ddfbbfd0b2470c/sphinxcontrib_htmlhelp-2.1.0.tar.gz"
    sha256 "c9e2916ace8aad64cc13a0d233ee22317f2b9025b9cf3295249fa985cc7082e9"
  end

  resource "sphinxcontrib-jsmath" do
    url "https://files.pythonhosted.org/packages/b2/e8/9ed3830aeed71f17c026a07a5097edcf44b692850ef215b161b8ad875729/sphinxcontrib-jsmath-1.0.1.tar.gz"
    sha256 "a9925e4a4587247ed2191a22df5f6970656cb8ca2bd6284309578f2153e0c4b8"
  end

  resource "sphinxcontrib-qthelp" do
    url "https://files.pythonhosted.org/packages/68/bc/9104308fc285eb3e0b31b67688235db556cd5b0ef31d96f30e45f2e51cae/sphinxcontrib_qthelp-2.0.0.tar.gz"
    sha256 "4fe7d0ac8fc171045be623aba3e2a8f613f8682731f9153bb2e40ece16b9bbab"
  end

  resource "sphinxcontrib-serializinghtml" do
    url "https://files.pythonhosted.org/packages/3b/44/6716b257b0aa6bfd51a1b31665d1c205fb12cb5ad56de752dfa15657de2f/sphinxcontrib_serializinghtml-2.0.0.tar.gz"
    sha256 "e9d912827f872c029017a53f0ef2180b327c3f7fd23c87229f7a8e8b70031d4d"
  end

  resource "stack-data" do
    url "https://files.pythonhosted.org/packages/28/e3/55dcc2cfbc3ca9c29519eb6884dd1415ecb53b0e934862d3559ddcb7e20b/stack_data-0.6.3.tar.gz"
    sha256 "836a778de4fec4dcd1dcd89ed8abff8a221f58308462e1c4aa2a3cf30148f0b9"
  end

  resource "sympy" do
    url "https://files.pythonhosted.org/packages/83/d3/803453b36afefb7c2bb238361cd4ae6125a569b4db67cd9e79846ba2d68c/sympy-1.14.0.tar.gz"
    sha256 "d3d3fe8df1e5a0b42f0e7bdf50541697dbe7d23746e894990c030e2b05e72517"
  end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/06/61/53d562a57b28c08eda40b258c0f975e360541943ad7c7bef897a40caafda/tornado-6.5.10.tar.gz"
    sha256 "a6b1ccd08c04b4a06fb5aeb381be99de5ad1e5375c1785e31d78c880feb57687"
  end

  resource "traitlets" do
    url "https://files.pythonhosted.org/packages/2c/2e/a7fbfe268c8a3b32546930c0297c101d65a4a14c304ad5790a9f478f0e4e/traitlets-5.16.1.tar.gz"
    sha256 "ed900c2b631aa3a112811139fa97b8d2c3bad5e989656bba4b7e52c7852c18c1"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/f6/cc/6253133b5bb138fc3306cebfbda2c520f545d36b5be2c7255cc528bb45d6/typing_extensions-4.16.0.tar.gz"
    sha256 "dc983d19a509c94dba722ee6abd33940f7c05a89e243c47e907eb4db6f1a43e5"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/e3/05/b17359e1cefb4f909b5e40b1b90a496d987258916dbbf88e842c729f510e/urllib3-2.8.0.tar.gz"
    sha256 "63bf2ead4c879426ebf22ef2a781eeb4aa3b4ae798a0435506f8687fd5bb9b63"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/dc/ac/3a943d2792c9bb368aaa8b50121c0f778460ba2d7fbdc0a0366201d9e761/wcwidth-0.9.1.tar.gz"
    sha256 "5823209b0d43af322ce698c689380d7c15ca31fa8e6e3be8459f27031bef0af5"
  end

  resource "widgetsnbextension" do
    url "https://files.pythonhosted.org/packages/bf/60/bc7a980fc78837d6ef8f5940cca4cadc433364503a4c4d42e2a7a0de3231/widgetsnbextension-4.0.16.tar.gz"
    sha256 "adeea0ae78f0856ee4945f413299801b82a0a01416303301f39a704282a37b73"
  end

  resource "sagemath-data-polytopes" do
    url "https://files.pythonhosted.org/packages/69/74/0a06131ee113a0022c52f4b6517fbeae6551e839472acc2264676167fea0/sagemath_data_polytopes-20170220.1.tar.gz"
    sha256 "78e742c0f7d46132cd874041094a5aaa64a7978c3d35ff7b9cecab4fe1f1814d"
  end

  resource "sagemath-data-graphs" do
    url "https://files.pythonhosted.org/packages/82/7b/2c18e019b90d9b0bdd84a83d6bd76450c5610761938308265518f17d17d8/sagemath_data_graphs-20210214.1.tar.gz"
    sha256 "2d021f4df20c4b5026e9d3167e485c54739e34f37b824c190441eecdd0abb5dd"
  end

  resource "sagemath-data-elliptic-curves" do
    url "https://files.pythonhosted.org/packages/7d/ab/ef83f5504fbbe3e08ded3dfb91fec6c9e051219499fcbe511b18d9dac5b7/sagemath_data_elliptic_curves-0.8.2.tar.gz"
    sha256 "5540a8d91eb6b189d5a2960c2a2e3b3b671e5969be8c36ddb51b7ac4eed05596"
  end

  # Sage PR #42878: discover the renamed Python data distributions.
  patch do
    url "https://github.com/sagemath/sage/commit/489c311673529a58e208c77583a9f426459993c1.patch?full_index=1"
    sha256 "fcbd6688d7553731c97a80e4cd5482c5915265316e6b03fbe9ee8afbf3400b1e"
  end

  patch do
    url "https://github.com/sagemath/sage/commit/014fec56e64246e83c9ae5a65b5494d89f969adf.patch?full_index=1"
    sha256 "c8efcfa23d1a1b9db3fc7bb4bdab6acec474d0feed88223d5f06d1582d3fe7f8"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| (f.opt_libexec/"bin/python").to_s }
  end

  def install
    # The tap's MeatAxe formula installs its multiplication tables in lib.
    inreplace "src/sage/env.py",
              'MTXLIB = var("MTXLIB", join(SAGE_SHARE, "meataxe"))',
              "MTXLIB = var(\"MTXLIB\", \"#{formula_opt_lib("dimpase/tap/meataxe")}\")"

    if OS.linux?
      inreplace "src/meson.build", "blas = dependency(blas_order)", "blas = dependency('openblas')"

      # Select the assembler that understands Homebrew GCC's ARM64 directives.
      ENV.append "CFLAGS", "-B#{formula_opt_bin("binutils")}/"
      ENV.append "CXXFLAGS", "-B#{formula_opt_bin("binutils")}/"
    end
    ENV["FREETYPE_DIR"] = formula_opt_prefix("freetype")
    ENV["QHULL_DIR"] = formula_opt_prefix("qhull")
    ENV["ZMQ_PREFIX"] = formula_opt_prefix("zeromq")
    ENV["PARI_DIR"] = formula_opt_prefix("pari")
    ENV["BOOST_ROOT"] = formula_opt_prefix("boost")

    setup_args = ["-Dbuild-docs=false", "-Ddefer_feature_checks=true", "--wrap-mode=nofallback"]
    %w[bliss brial coxeter3 eclib libbraiding libhomfly mcqd meataxe rankwidth sirocco tdlib].each do |feature|
      setup_args << "-D#{feature}=enabled"
    end
    setup_args = setup_args.map { |arg| "--config-settings=setup-args=#{arg}" }

    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      private_prefix = libexec/"python#{python_version}"
      site_packages = Language::Python.site_packages(python3)
      ENV["PYTHONPATH"] = "#{private_prefix/site_packages}:#{prefix/site_packages}"
      ENV.prepend_path "PATH", private_prefix/"bin"

      resources.reject { |r| r.name == "cypari2" }.each do |r|
        r.stage do
          args = std_pip_args(prefix:          private_prefix,
                              build_isolation: ["pplpy", "primecountpy"].exclude?(r.name))
          if ["matplotlib", "pplpy", "primecountpy"].include?(r.name)
            args += ["--config-settings=setup-args=--wrap-mode=nofallback"]
          end
          if r.name == "matplotlib"
            args += ["--config-settings=setup-args=-Dsystem-freetype=true",
                     "--config-settings=setup-args=-Dsystem-qhull=true",
                     "--config-settings=setup-args=-Dsystem-libraqm=true"]
          end
          system python3, "-m", "pip", "install", *args, "."
        end
      end

      resource("cypari2").stage do
        system python3, "-m", "pip", "install", *std_pip_args(prefix: private_prefix), "."
      end

      system python3, "-m", "pip", "install", *std_pip_args,
             *setup_args,
             "--config-settings=compile-args=-j#{ENV.make_jobs}", "."

      # Expose the private dependencies to this Homebrew Python interpreter.
      (prefix/site_packages/"sagemath-dependencies.pth").write <<~EOS
        import site; site.addsitedir('#{opt_libexec/"python#{python_version}"/site_packages}')
      EOS
      mv bin/"sage", bin/"sage-#{python_version}"
    end
    bin.install_symlink "sage-3.14" => "sage"
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      from sage.all import *
      assert factor(123456789).value() == 3**2 * 3607 * 3803
      R = PolynomialRing(QQ, "x")
      x = R.gen()
      assert (x**2 - 1).factor().value() == x**2 - 1
      assert GF(16).multiplicative_generator().multiplicative_order() == 15
      assert gap.SmallGroup(24, 3).Size().sage() == 24
      assert pari(2).isprime()
      assert maxima("2+2").sage() == 4
      assert BooleanPolynomialRing(3, "a").ngens() == 3
      from sage.features.databases import DatabaseCremona, DatabaseGraphs, DatabaseReflexivePolytopes
      assert DatabaseCremona("cremona_mini").is_present()
      assert DatabaseGraphs().is_present()
      assert DatabaseReflexivePolytopes().is_present()
    PYTHON
    pythons.each do |python3|
      system python3, testpath/"test.py"
    end
    assert_equal "4", shell_output("#{bin}/sage -c 'print(2+2)'").strip
  end
end
