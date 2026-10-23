class SagemathDeps < Formula
  desc "Native and Python dependencies for building and running SageMath"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta4.tar.gz"
  sha256 "0b2836cb6caf77bfb5e76934eae07193387fa342976e08378d321416b6504ece"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-tap/releases/download/sagemath-deps-11.0.beta4"
    sha256 cellar: :any, arm64_tahoe:  "c93abc73958ef08b3cdb8c905df37bc1a16dad31ab29a2f79ae6549d78bcdcc3"
    sha256 cellar: :any, arm64_linux:  "4a9840afd75e65cbf4e6ee8c05f78b20e7ec18de805e5fd03dc2a77a10dc8a3f"
    sha256 cellar: :any, x86_64_linux: "cf6c05631f3e5297fdf333573f98378a70ae3b57343c29a638f03aa20c6b06ce"
  end

  # Keep build tools installed when this dependency environment is bottled.
  # They are also needed to build sagelib separately from a checkout.
  depends_on "bdw-gc"
  depends_on "boost"
  depends_on "cddlib"
  depends_on "cmake"
  depends_on "dimpase/gap/gap"
  depends_on "dimpase/tap/bliss"
  depends_on "dimpase/tap/brial"
  depends_on "dimpase/tap/cliquer"
  depends_on "dimpase/tap/coxeter3"
  depends_on "dimpase/tap/cvxopt"
  depends_on "dimpase/tap/cypari2"
  depends_on "dimpase/tap/cysignals"
  depends_on "dimpase/tap/eclib"
  depends_on "dimpase/tap/gmp-ecm"
  depends_on "dimpase/tap/gmpy2"
  depends_on "dimpase/tap/iml"
  depends_on "dimpase/tap/lcalc"
  depends_on "dimpase/tap/libbraiding"
  depends_on "dimpase/tap/libhomfly"
  depends_on "dimpase/tap/lrcalc"
  depends_on "dimpase/tap/matplotlib-accelerate"
  depends_on "dimpase/tap/maxima-ecl"
  depends_on "dimpase/tap/mcqd"
  depends_on "dimpase/tap/meataxe"
  depends_on "dimpase/tap/pari"
  depends_on "dimpase/tap/pari-elldata"
  depends_on "dimpase/tap/pari-galdata"
  depends_on "dimpase/tap/pari-galpol"
  depends_on "dimpase/tap/pari-seadata"
  depends_on "dimpase/tap/planarity"
  depends_on "dimpase/tap/pplpy"
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
  depends_on "libomp" if OS.mac?
  depends_on "libpng"
  depends_on "libraqm"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "m4ri"
  depends_on "m4rie"
  depends_on "macaulay2/tap/fflas-ffpack"
  depends_on "macaulay2/tap/gfan"
  depends_on "macaulay2/tap/givaro"
  depends_on "macaulay2/tap/linbox"
  depends_on "macaulay2/tap/normaliz"
  depends_on "macaulay2/tap/palp"
  depends_on "meson"
  depends_on "mpfi"
  depends_on "mpfr"
  depends_on "nauty"
  depends_on "ninja"
  depends_on "ntl"
  depends_on "pillow" => :no_linkage
  depends_on "pkgconf"
  depends_on "ppl"
  depends_on "primecount"
  depends_on "pybind11"
  depends_on "python@3.14"
  depends_on "qhull"
  depends_on "singular"
  depends_on "webp"
  # Kernel messaging dependencies are required; JupyterLab/Notebook run separately.
  depends_on "zeromq"

  on_macos do
    depends_on "dimpase/tap/numpy-accelerate"
    depends_on "dimpase/tap/pillow-python313" => :no_linkage
    depends_on "dimpase/tap/scipy-accelerate"
    depends_on macos: :sonoma
    depends_on "python@3.13"

    resource "appnope" do
      url "https://files.pythonhosted.org/packages/11/f7/a82489c2b6ebe32d3e2831895ae19c77861f0eadf3bb16034484d965dbb2/appnope-1.0.0.tar.gz"
      sha256 "685db59cb6043c3c2e528adc0b3bce3a5f8d09bcf7492c6ea650d1b7421f3c49"
    end
  end

  on_linux do
    depends_on "binutils"
    depends_on "numpy"
    depends_on "openblas"
    depends_on "patchelf"
    depends_on "scipy"
    depends_on "zlib-ng-compat"
  end

  pypi_packages package_name:     "sagemath",
                extra_packages:   %w[
                  cython jinja2 lrcalc memory-allocator meson-python packaging
                  pyproject-metadata sagemath-data-elliptic-curves sagemath-data-graphs
                  sagemath-data-polytopes setuptools wheel
                ],
                exclude_packages: %w[
                  cvxopt cypari2 cysignals gmpy2 matplotlib meson numpy pillow pplpy pybind11 scipy sphinx
                ]

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/70/b3/c19426f783614d625699a4b247faf628ea9ab1db228674491767b417f9e1/setuptools-84.2.1.tar.gz"
    sha256 "3ff8b3b5492a0aa66960f4419365a86b84e013070d4313e4d4a6894f5d64d6bc"
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

  resource "memory-allocator" do
    url "https://files.pythonhosted.org/packages/09/a9/2a966afb82df71f759e0c46cef0dc46d1f535897c6b341fafb2bd5e08b29/memory_allocator-0.2.0.tar.gz"
    sha256 "675d3c91019db98c97441de73d5c648821e5ae813f3f54cd09863d474b48fe26"
  end

  resource "asttokens" do
    url "https://files.pythonhosted.org/packages/25/1e/faf0f247f6f881b98fc4d6d07e14085cb89d13665084e6d6ac1dc2c03d0b/asttokens-3.0.2.tar.gz"
    sha256 "3ecdbd8f2cc195f53ccada3a613538bb5f9ef6f6869129f13e03c30a677b8fe2"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/a6/bd/1436c50cc46699de0230fbaacc1d1de7bfec413176099949e9d5112e88f2/certifi-2026.10.19.tar.gz"
    sha256 "035c1e85572b141bf1c3a3eff0e33a8eb74917522f2559075ff8d2fea780a1ae"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/33/1c/f41d4e74c28ab327ff3acd36053f7ea506c55872d7a90b0fa71aa3ab0c89/charset_normalizer-3.5.2.tar.gz"
    sha256 "39de2a259fc954455c57274dc94c79d5842774e1247a016aff30bc0efed0f4ef"
  end

  resource "comm" do
    url "https://files.pythonhosted.org/packages/4c/13/7d740c5849255756bc17888787313b61fd38a0a8304fc4f073dfc46122aa/comm-0.2.3.tar.gz"
    sha256 "2dc8048c10962d55d7ad693be1e7045d891b7ce8d999c97963a5e3e99c055971"
  end

  resource "conway-polynomials" do
    url "https://files.pythonhosted.org/packages/a4/73/2601b755e76fa1d90f19541d80d43b97bfa1d5c9bc284e79c8f8180ba317/conway_polynomials-0.10.tar.gz"
    sha256 "4f619f64f81a3eb16c4e26c5a284feeec27a6f4aad647643e79af289801ae0f3"
  end

  resource "debugpy" do
    url "https://files.pythonhosted.org/packages/44/9d/3cb6693342acf96802dba89934a5b8da43c201d764ebd1f2c0514a3d42bd/debugpy-1.8.22.tar.gz"
    sha256 "e489c7268e1c7b41e13b438d9c533d2a7af73fb59bf8cd30fead8286c1c39c4e"
  end

  resource "executing" do
    url "https://files.pythonhosted.org/packages/52/92/8a611141e42930c0f194f7504063ab87dfe970cf1a5af28e7703df448734/executing-2.3.0.tar.gz"
    sha256 "15919cb5d667e5cb4e099511971d00d659573fff2dd5c4e6cd8b71636c7858d2"
  end

  resource "fpylll" do
    url "https://files.pythonhosted.org/packages/6b/46/a2ee5fb35426405f76739958b16427c0cc2e06a694b8532ab7ec43ae1683/fpylll-0.6.4.tar.gz"
    sha256 "711d60d8ada46a410932cc45587728b4c7f4ea38a9b8d0be061f5ce098632ecd"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/f5/08/8eea9d4b8302028f3abb2c0813953f7aec26d33b7a8960ed760e65ff29fa/idna-3.20.tar.gz"
    sha256 "a7db850025b95ded1eae8a46181a1a6c56c92c96f0e2b005d9ff8dc0210cab44"
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
    url "https://files.pythonhosted.org/packages/a3/a4/4692ecd7fa700ac1066b1c1f6cadef60aa2e01e5e364710235137d823e0a/jedi-0.20.1.tar.gz"
    sha256 "2f71208c3f9c1bca057c0e90d3f272aba44ace88fc4067d7587e9e069331b7e5"
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

  resource "lrcalc" do
    url "https://files.pythonhosted.org/packages/a9/65/612c8c5b91dd5c1c576009c0501fc49be4e65383d04bde6d44edb1522abd/lrcalc-2.1.tar.gz"
    sha256 "e3a0509aeda487b412b391a52e817ca36b5c063a8305e09fd54d53259dd6aaa9"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/38/9b/e422a865e1d5d57d0e509b4e0bf1c1a70a7f6382c29a5aa428df994c8bc8/markupsafe-3.0.4.tar.gz"
    sha256 "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6"
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
    url "https://files.pythonhosted.org/packages/32/2c/70e3b6bb2189cfd260280b7e1042bd622949a258663f95e887fada4ac1e6/nest_asyncio2-1.7.4.tar.gz"
    sha256 "995b1409d926ec55e0876ea39a69bffdd8852cf1db3652c177e8c8ffdbcaf3cc"
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

  resource "pkgconfig" do
    url "https://files.pythonhosted.org/packages/52/fd/0adde075cd3bfecd557bc7d757e00e231d34d8a6edb4c8d1642759254c21/pkgconfig-1.6.0.tar.gz"
    sha256 "4a5a6631ce937fafac457104a40d558785a658bbdca5c49b6295bc3fd651907f"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/58/e6/d0abbb256b44e6a05748c6942511ff67db8dbb068de0c35b24bf1b395b09/platformdirs-4.13.5.tar.gz"
    sha256 "05831adf87d392760f4b5c3a0a95579ab5a10b18b9b9bd43680dcb47544788a0"
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

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/49/2e/ced460408999b33da6b31b0021b0f37d329e202d4169aeb164493778f25b/pygments-2.21.0.tar.gz"
    sha256 "610ca751c9bc2492b38eb9a38a7fbc93edbbb2d7182edaf34e66ae493dee5c8c"
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

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
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
    url "https://files.pythonhosted.org/packages/d0/02/5f549b1ad5da6267ed1e1fac2eef69257b1979cc812497002499b7895ff9/tornado-6.6.tar.gz"
    sha256 "34c4aa916d7f2b2d5cadee2c6850f5a4a7f3d688cbf58399ea9bd3057af4abd5"
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
    url "https://files.pythonhosted.org/packages/69/4a/82d61476a1ccc20d43d0805724c5de4baa4971131a8db1816705ef53fe16/wcwidth-0.9.3.tar.gz"
    sha256 "dfe7cfbd4cb59db9fe0931bd6091ab4a95b3acc5d56bfb50fa9fef0ccba5dc5c"
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

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| (f.opt_libexec/"bin/python").to_s }
  end

  def write_development_environment(python_version)
    # A pip build outside Homebrew does not get superenv's native search paths.
    native_prefixes = deps.reject { |d| d.name.start_with?("python@") }
                          .map { |d| formula_opt_prefix(d.name) }
    paths = {
      "PATH"              => native_prefixes.map { |p| p/"bin" },
      "CPATH"             => native_prefixes.map { |p| p/"include" },
      "LIBRARY_PATH"      => native_prefixes.map { |p| p/"lib" },
      "PKG_CONFIG_PATH"   => native_prefixes.flat_map { |p| [p/"lib/pkgconfig", p/"share/pkgconfig"] },
      "CMAKE_PREFIX_PATH" => native_prefixes,
    }
    paths.transform_values! { |entries| entries.select(&:directory?) }
    paths["PATH"].unshift(opt_libexec/"python#{python_version}/bin")
    script = "# Source after activating a Homebrew Python #{python_version} virtual environment.\n"
    paths.each do |name, entries|
      # Keep packages installed in the development venv ahead of bundled tools.
      venv = (name == "PATH") ? "${VIRTUAL_ENV:+$VIRTUAL_ENV/bin:}" : ""
      script += "export #{name}=\"#{venv}#{entries.join(":")}${#{name}:+:$#{name}}\"\n"
    end
    script += <<~SH
      export PARI_DIR="#{formula_opt_prefix("dimpase/tap/pari")}"
      export BOOST_ROOT="#{formula_opt_prefix("boost")}"
      export MTXLIB="#{formula_opt_lib("dimpase/tap/meataxe")}"
    SH
    if OS.linux?
      gcc = deps.find { |d| d.name == "gcc" }.to_formula
      script += <<~SH
        export CC="${CC:-#{gcc.opt_bin}/gcc-#{gcc.version.major}}"
        export CXX="${CXX:-#{gcc.opt_bin}/g++-#{gcc.version.major}}"
        export CFLAGS="-B#{formula_opt_bin("binutils")}/${CFLAGS:+ $CFLAGS}"
        export CXXFLAGS="-B#{formula_opt_bin("binutils")}/${CXXFLAGS:+ $CXXFLAGS}"
      SH
    end
    (pkgshare/"python#{python_version}-env.sh").write script
  end

  def write_python_paths(python_version, site_packages)
    private_site = opt_libexec/"python#{python_version}"/site_packages
    global_site = HOMEBREW_PREFIX/site_packages
    # Prefer these resources to Homebrew's other Python packages, while allowing
    # a development venv to override them with its own installed packages.
    # Linux Python also supplies packages (including wheel) in its own keg.
    (prefix/site_packages/"sagemath-deps.pth").write <<~EOS
      import site, sys; site.addsitedir('#{private_site}'); sys.path.remove('#{private_site}'); sys.path.insert(min((sys.path.index(p) for p in ['#{global_site}', *site.getsitepackages([sys.base_prefix, sys.base_exec_prefix])] if p in sys.path), default=len(sys.path)), '#{private_site}')
    EOS
  end

  def install
    if OS.linux?
      # Select the assembler that understands Homebrew GCC's ARM64 directives.
      ENV.append "CFLAGS", "-B#{formula_opt_bin("binutils")}/"
      ENV.append "CXXFLAGS", "-B#{formula_opt_bin("binutils")}/"
    end
    ENV["FREETYPE_DIR"] = formula_opt_prefix("freetype")
    ENV["QHULL_DIR"] = formula_opt_prefix("qhull")
    ENV["ZMQ_PREFIX"] = formula_opt_prefix("zeromq")
    ENV["PARI_DIR"] = formula_opt_prefix("dimpase/tap/pari")
    ENV["BOOST_ROOT"] = formula_opt_prefix("boost")

    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      private_prefix = libexec/"python#{python_version}"
      site_packages = Language::Python.site_packages(python3)
      ENV["PYTHONPATH"] = "#{private_prefix/site_packages}:#{prefix/site_packages}"
      ENV.prepend_path "PATH", private_prefix/"bin"

      resources.each do |r|
        r.stage do
          args = std_pip_args(prefix:          private_prefix,
                              build_isolation: ["lrcalc", "primecountpy"].exclude?(r.name))
          if r.name == "primecountpy"
            args += ["--config-settings=setup-args=--wrap-mode=nofallback"]
          end
          system python3, "-m", "pip", "install", *args, "."
        end
      end

      write_python_paths(python_version, site_packages)
      write_development_environment(python_version)
    end
  end

  def caveats
    <<~EOS
      The Python dependencies are available to Homebrew Python without installing
      sagelib. To use them in a virtual environment:
        #{formula_opt_bin("python@3.14")}/python3.14 -m venv --system-site-packages sage-venv
        source sage-venv/bin/activate
        source #{opt_pkgshare}/python3.14-env.sh

      The environment script exposes the native headers, libraries and build tools
      for a separate sagelib build. Use pip's --no-build-isolation and --no-deps
      options to reuse these dependencies.
    EOS
  end

  test do
    refute_path_exists bin/"sage"
    (testpath/"native_probe.pyx").write <<~PYX
      cdef extern from "gmp.h":
          const char *gmp_version
      def version():
          return gmp_version.decode("ascii")
    PYX
    (testpath/"setup.py").write <<~PYTHON
      from setuptools import Extension, setup
      from Cython.Build import cythonize
      setup(ext_modules=cythonize([Extension("native_probe", ["native_probe.pyx"], libraries=["gmp"])]))
    PYTHON
    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      site_packages = Language::Python.site_packages(python3)
      private_site = libexec/"python#{python_version}"/site_packages
      refute_path_exists prefix/site_packages/"sage"
      refute_path_exists private_site/"sage"
      venv = testpath/"venv-#{python_version}"
      system python3, "-m", "venv", "--system-site-packages", venv
      system venv/"bin/python", "-c", <<~PYTHON
        import importlib.metadata
        import pathlib
        import sys

        assert sys.prefix != sys.base_prefix

        # Verify that all resources come from this formula, even when an older
        # unsplit Sage installation is also present on the machine.
        root = pathlib.Path("#{private_site}").resolve()
        for name in #{resources.map(&:name).to_json}:
            dist = importlib.metadata.distribution(name)
            assert pathlib.Path(dist.locate_file("")).resolve() == root, (name, dist.locate_file(""))
        assert not list(root.glob("sagemath-[0-9]*.dist-info")), "sagelib must be installed separately"
        import Cython, mesonpy, memory_allocator, jinja2, packaging
        import cysignals, gmpy2, numpy, scipy, matplotlib, PIL, ipykernel, ipywidgets
        import networkx, requests
        from sympy import Symbol, factor
        x = Symbol("x")
        assert factor(x**2 - 1) == (x - 1)*(x + 1)
        from cypari2 import Pari
        assert Pari()(101).isprime()
        from fpylll import IntegerMatrix, LLL
        a = IntegerMatrix.from_matrix([[1, 1], [1, 0]])
        LLL.reduction(a)
        assert abs(a[0, 0]*a[1, 1] - a[0, 1]*a[1, 0]) == 1
        import lrcalc
        assert lrcalc.lrcoef([3, 2, 1], [2, 1], [2, 1]) == 2
        from primecountpy import prime_pi
        assert prime_pi(100) == 25
        import ppl
        x = ppl.Variable(0)
        poly = ppl.C_Polyhedron(ppl.Constraint_System([x >= 0, x <= 1]))
        assert len(poly.minimized_generators()) == 2
        from cvxopt import cholmod, matrix, spmatrix
        a = spmatrix([2.0, 3.0], [0, 1], [0, 1])
        b = matrix([4.0, 9.0])
        cholmod.linsolve(a, b)
        assert max(abs(b[0] - 2.0), abs(b[1] - 3.0)) < 1e-7
      PYTHON
      system "bash", "-c", <<~SH
        set -eu
        source "#{venv}/bin/activate"
        source "#{pkgshare}/python#{python_version}-env.sh"
        test "$(command -v python)" = "#{venv}/bin/python"
        pkg-config --exists brial eclib flint gmp
        python setup.py build_ext --inplace --force
        python -c 'import native_probe; assert native_probe.version().startswith("#{deps.find { |d| d.name == "gmp" }.to_formula.version.major_minor}")'
      SH
      # Packages deliberately installed in the venv must override the baseline.
      (venv/site_packages/"sympy.py").write "VENV_OVERRIDE = True\n"
      system venv/"bin/python", "-c", "import sympy; assert sympy.VENV_OVERRIDE"
    end
  end
end
