class SagemathDocbuildDeps < Formula
  desc "Dependencies for building SageMath HTML documentation"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta1.tar.gz"
  sha256 "fc3e2af93024456c3898243a49dcfa721292b85f264c4c3a94c2ed22d3385091"
  license "GPL-2.0-or-later"

  depends_on "dimpase/tap/sagemath-deps"
  depends_on "python@3.14"

  on_macos do
    depends_on macos: :sonoma
    depends_on "python@3.13"

    resource "rpds-py-python313" do
      on_arm do
        url "https://files.pythonhosted.org/packages/f3/6b/686d9dc4359a8f163cfbbf89ee0b4e586431de22fe8248edb63a8cf50d49/rpds_py-2026.6.3-cp313-cp313-macosx_11_0_arm64.whl", using: :nounzip
        sha256 "f4d78253f6996be4901669ad25319f842f740eccf4d58e3c7f3dd39e6dde1d8f"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/a4/9e/b818ee580026ec578138e961027a68820c40afeb1ec8f6819b54fb99e196/rpds_py-2026.6.3-cp313-cp313-macosx_10_12_x86_64.whl", using: :nounzip
        sha256 "3cfe765c1da0072636ca06628261e0ea05688e160d5c8a03e0217c3854037223"
      end
    end
  end

  # Match Sage's docs dependency group and lockfile. Reuse packages supplied by
  # sagemath-deps; keep the extra documentation packages in their own prefixes.
  # Wheels include Furo's compiled theme assets without a Node.js build.
  resource "accessible-pygments" do
    url "https://files.pythonhosted.org/packages/8d/3f/95338030883d8c8b91223b4e21744b04d11b161a3ef117295d8241f50ab4/accessible_pygments-0.0.5-py3-none-any.whl", using: :nounzip
    sha256 "88ae3211e68a1d0b011504b2ffc1691feafce124b845bd072ab6f9f66f34d4b7"
  end

  resource "alabaster" do
    url "https://files.pythonhosted.org/packages/7e/b3/6b4067be973ae96ba0d615946e314c5ae35f9f993eca561b356540bb0c2b/alabaster-1.0.0-py3-none-any.whl", using: :nounzip
    sha256 "fc6786402dc3fcb2de3cabd5fe455a2db534b371124f1f21de8731783dec828b"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/64/b4/17d4b0b2a2dc85a6df63d1157e028ed19f90d4cd97c36717afef2bc2f395/attrs-26.1.0-py3-none-any.whl", using: :nounzip
    sha256 "c647aa4a12dfbad9333ca4e71fe62ddc36f4e63b2d260a37a8b83d2f043ac309"
  end

  resource "babel" do
    url "https://files.pythonhosted.org/packages/77/f5/21d2de20e8b8b0408f0681956ca2c69f1320a3848ac50e6e7f39c6159675/babel-2.18.0-py3-none-any.whl", using: :nounzip
    sha256 "e2b422b277c2b9a9630c1d7903c2a00d0830c409c59ac8cae9081c92f1aeba35"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/88/c6/92fcd42f1ba33e1184263f25bfabf3d27c383410470f169e4b8163bf9c17/beautifulsoup4-4.15.0-py3-none-any.whl", using: :nounzip
    sha256 "d6f88de62e1d4e38ecb1077eb9724cd0eff29d2a08ca16a401e9b9e93f117cf9"
  end

  resource "bleach" do
    url "https://files.pythonhosted.org/packages/58/9d/40b6267367182187139a4000b82a3b287d84d745bccd808e75d916920e9d/bleach-6.4.0-py3-none-any.whl", using: :nounzip
    sha256 "4b6b6a54fff2e69a3dde9d21cc6301220bee3c3cb792187d11403fd795031081"
  end

  resource "defusedxml" do
    url "https://files.pythonhosted.org/packages/07/6c/aa3f2f849e01cb6a001cd8554a88d4c77c5c1a31c95bdf1cf9301e6d9ef4/defusedxml-0.7.1-py2.py3-none-any.whl", using: :nounzip
    sha256 "a352e7e428770286cc899e2542b6cdaedb2b4953ff269a210103ec58f6198a61"
  end

  resource "docutils" do
    url "https://files.pythonhosted.org/packages/02/10/5da547df7a391dcde17f59520a231527b8571e6f46fc8efb02ccb370ab12/docutils-0.22.4-py3-none-any.whl", using: :nounzip
    sha256 "d0013f540772d1420576855455d050a2180186c91c15779301ac2ccb3eeb68de"
  end

  resource "fastjsonschema" do
    url "https://files.pythonhosted.org/packages/49/82/2755c7c982086f00d4dab85bc120ec35045a9fc2191893a6ce79afe94443/fastjsonschema-2.22.2-py3-none-any.whl", using: :nounzip
    sha256 "0fb3915616adac85ccfdd737d26be1089845d2019819505b42d39888458f74d4"
  end

  resource "furo" do
    url "https://files.pythonhosted.org/packages/f4/b2/50e9b292b5cac13e9e81272c7171301abc753a60460d21505b606e15cf21/furo-2025.12.19-py3-none-any.whl", using: :nounzip
    sha256 "bb0ead5309f9500130665a26bee87693c41ce4dbdff864dbfb6b0dae4673d24f"
  end

  resource "imagesize" do
    url "https://files.pythonhosted.org/packages/01/f9/575c8d760eae1fc99651b7cc5efd96ad5379ca4d6b53750b0fb4fe983f34/imagesize-2.0.1-py3-none-any.whl", using: :nounzip
    sha256 "ea0c9a0384df69ed86a943a15cde37d0360b82491b3910dc2215e202e62b5b02"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/69/90/f63fb5873511e014207a475e2bb4e8b2e570d655b00ac19a9a0ca0a385ee/jsonschema-4.26.0-py3-none-any.whl", using: :nounzip
    sha256 "d489f15263b8d200f8387e64b4c3a75f06629559fb73deb8fdfb525f2dab50ce"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/41/45/1a4ed80516f02155c51f51e8cedb3c1902296743db0bbc66608a0db2814f/jsonschema_specifications-2025.9.1-py3-none-any.whl", using: :nounzip
    sha256 "98802fee3a11ee76ecaca44429fda8a41bff98b00a0f2838151b113f210cc6fe"
  end

  resource "jupyter-sphinx" do
    url "https://files.pythonhosted.org/packages/6f/1c/45251d4b9624e42b9e4f369dae2a64f5ea19b9387ba492ceb7be65343dda/jupyter_sphinx-0.5.3-py3-none-any.whl", using: :nounzip
    sha256 "a67b3208d4da5b3508dbb8260d3b359ae476c36c6c642747b78a2520e5be0b05"
  end

  resource "jupyterlab-pygments" do
    url "https://files.pythonhosted.org/packages/b1/dd/ead9d8ea85bf202d90cc513b533f9c363121c7792674f78e0d8a854b63b4/jupyterlab_pygments-0.3.0-py3-none-any.whl", using: :nounzip
    sha256 "841a89020971da1d8693f1a99997aefc5dc424bb1b251fd6322462a1b8842780"
  end

  resource "mistune" do
    url "https://files.pythonhosted.org/packages/77/e4/288365afae98953bc01de09f686f40d8ee84578135aa7767d5d4e60b5278/mistune-3.3.4-py3-none-any.whl", using: :nounzip
    sha256 "ee015381e955e370962968befe1d729ab60fafb6a715ac6751763fbce38c8d4a"
  end

  resource "mathjax" do
    url "https://github.com/mathjax/MathJax/archive/refs/tags/3.2.0.tar.gz"
    sha256 "6847f1cfdd980afbe31b466474da301a56ab859a67d8035442b052dd4ac2fa03"
  end

  resource "nbclient" do
    url "https://files.pythonhosted.org/packages/36/c9/94d73e5a01c5b926c3fa2496e97d7a8dc28ed5a77c0b2ed712f1a62e6694/nbclient-0.11.0-py3-none-any.whl", using: :nounzip
    sha256 "ef7fa0d59d6e1d41103933d8a445a18d5de860ca6b613b87b8574accdb3c2895"
  end

  resource "nbconvert" do
    url "https://files.pythonhosted.org/packages/67/f8/bb0a9d5f46819c821dc1f004aa2cc29b1d91453297dbf5ff20470f00f193/nbconvert-7.17.1-py3-none-any.whl", using: :nounzip
    sha256 "aa85c087b435e7bf1ffd03319f658e285f2b89eccab33bc1ba7025495ab3e7c8"
  end

  resource "nbformat" do
    url "https://files.pythonhosted.org/packages/1a/69/ee613f74085ca7103f79cd08d579c4f3177d1d26e5d3d9528d2d6536a707/nbformat-5.11.1-py3-none-any.whl", using: :nounzip
    sha256 "cc6698fa75f4fab8755ead786317815f13a6fee3b53311c0abb1a8b51d52f7ec"
  end

  resource "pandocfilters" do
    url "https://files.pythonhosted.org/packages/ef/af/4fbc8cab944db5d21b7e2a5b8e9211a03a79852b1157e2c102fcc61ac440/pandocfilters-1.5.1-py2.py3-none-any.whl", using: :nounzip
    sha256 "93be382804a9cdb0a7267585f157e5d1731bbe5545a85b268d6f5fe6232de2bc"
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/2c/58/ca301544e1fa93ed4f80d724bf5b194f6e4b945841c5bfd555878eea9fcb/referencing-0.37.0-py3-none-any.whl", using: :nounzip
    sha256 "381329a9f99628c9069361716891d34ad94af76e461dcb0335825aecc7692231"
  end

  resource "roman-numerals" do
    url "https://files.pythonhosted.org/packages/04/54/6f679c435d28e0a568d8e8a7c0a93a09010818634c3c3907fc98d8983770/roman_numerals-4.1.0-py3-none-any.whl", using: :nounzip
    sha256 "647ba99caddc2cc1e55a51e4360689115551bf4476d90e8162cf8c345fe233c7"
  end

  resource "snowballstemmer" do
    url "https://files.pythonhosted.org/packages/4c/07/2ebca9b11fb9be7340a818d8d6f63feaebb146be2c4afbd6061701d6df6e/snowballstemmer-3.1.1-py3-none-any.whl", using: :nounzip
    sha256 "7e207fa178741da09cdee59d3ecec3827ad5f92b1fc5c9ff3755b639f71f5752"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/eb/dc/ad025c1ee131eba60c69f4dd5779b18fcf1e6b21a343e2162a84d5d133c7/soupsieve-2.9.2-py3-none-any.whl", using: :nounzip
    sha256 "8089a26fd974ca7a1f30276d3d8492ab266ab15af581642dfe8aa162e0c1c823"
  end

  resource "sphinx" do
    url "https://files.pythonhosted.org/packages/73/f7/b1884cb3188ab181fc81fa00c266699dab600f927a964df02ec3d5d1916a/sphinx-9.1.0-py3-none-any.whl", using: :nounzip
    sha256 "c84fdd4e782504495fe4f2c0b3413d6c2bf388589bb352d439b2a3bb99991978"
  end

  resource "sphinx-basic-ng" do
    url "https://files.pythonhosted.org/packages/3c/dd/018ce05c532a22007ac58d4f45232514cd9d6dd0ee1dc374e309db830983/sphinx_basic_ng-1.0.0b2-py3-none-any.whl", using: :nounzip
    sha256 "eb09aedbabfb650607e9b4b68c9d240b90b1e1be221d6ad71d61c52e29f7932b"
  end

  resource "sphinx-copybutton" do
    url "https://files.pythonhosted.org/packages/9e/48/1ea60e74949eecb12cdd6ac43987f9fd331156388dcc2319b45e2ebb81bf/sphinx_copybutton-0.5.2-py3-none-any.whl", using: :nounzip
    sha256 "fb543fd386d917746c9a2c50360c7905b605726b9355cd26e9974857afeae06e"
  end

  resource "sphinx-inline-tabs" do
    url "https://files.pythonhosted.org/packages/02/2b/e64e7de34663cff1df029ba4f05a86124315bd9eba3d3b78e64904bea7e0/sphinx_inline_tabs-2025.12.21.14-py3-none-any.whl", using: :nounzip
    sha256 "e685c782b58d4e01490bcc4e2367cf7135ec28e7283a05e89095394e4ca6e81a"
  end

  resource "sphinxcontrib-applehelp" do
    url "https://files.pythonhosted.org/packages/5d/85/9ebeae2f76e9e77b952f4b274c27238156eae7979c5421fba91a28f4970d/sphinxcontrib_applehelp-2.0.0-py3-none-any.whl", using: :nounzip
    sha256 "4cd3f0ec4ac5dd9c17ec65e9ab272c9b867ea77425228e68ecf08d6b28ddbdb5"
  end

  resource "sphinxcontrib-devhelp" do
    url "https://files.pythonhosted.org/packages/35/7a/987e583882f985fe4d7323774889ec58049171828b58c2217e7f79cdf44e/sphinxcontrib_devhelp-2.0.0-py3-none-any.whl", using: :nounzip
    sha256 "aefb8b83854e4b0998877524d1029fd3e6879210422ee3780459e28a1f03a8a2"
  end

  resource "sphinxcontrib-htmlhelp" do
    url "https://files.pythonhosted.org/packages/0a/7b/18a8c0bcec9182c05a0b3ec2a776bba4ead82750a55ff798e8d406dae604/sphinxcontrib_htmlhelp-2.1.0-py3-none-any.whl", using: :nounzip
    sha256 "166759820b47002d22914d64a075ce08f4c46818e17cfc9470a9786b759b19f8"
  end

  resource "sphinxcontrib-jsmath" do
    url "https://files.pythonhosted.org/packages/c2/42/4c8646762ee83602e3fb3fbe774c2fac12f317deb0b5dbeeedd2d3ba4b77/sphinxcontrib_jsmath-1.0.1-py2.py3-none-any.whl", using: :nounzip
    sha256 "2ec2eaebfb78f3f2078e73666b1415417a116cc848b72e5172e596c871103178"
  end

  resource "sphinxcontrib-qthelp" do
    url "https://files.pythonhosted.org/packages/27/83/859ecdd180cacc13b1f7e857abf8582a64552ea7a061057a6c716e790fce/sphinxcontrib_qthelp-2.0.0-py3-none-any.whl", using: :nounzip
    sha256 "b18a828cdba941ccd6ee8445dbe72ffa3ef8cbe7505d8cd1fa0d42d3f2d5f3eb"
  end

  resource "sphinxcontrib-serializinghtml" do
    url "https://files.pythonhosted.org/packages/52/a7/d2782e4e3f77c8450f727ba74a8f12756d5ba823d81b941f1b04da9d033a/sphinxcontrib_serializinghtml-2.0.0-py3-none-any.whl", using: :nounzip
    sha256 "6e2cb0eef194e10c27ec0023bfeb25badbbb5868244cf5bc5bdc04e4464bf331"
  end

  resource "tinycss2" do
    url "https://files.pythonhosted.org/packages/60/45/c7b5c3168458db837e8ceab06dc77824e18202679d0463f0e8f002143a97/tinycss2-1.5.1-py3-none-any.whl", using: :nounzip
    sha256 "3415ba0f5839c062696996998176c4a3751d18b7edaaeeb658c9ce21ec150661"
  end

  resource "webencodings" do
    url "https://files.pythonhosted.org/packages/77/c6/040cbc72480d789a5f40d63fb484d3106554c4dfa2d2b70ad5022057750f/webencodings-0.6.1-py3-none-any.whl", using: :nounzip
    sha256 "7fab6269c8bf237c657876b52058ccb182e861518d1c695c1a9aaa8c1c105d5b"
  end

  resource "rpds-py-python314" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/ba/54/f785cc3d3f60839ca57a5af4927a9f347b07b2799c373fc20f7949f87c7e/rpds_py-2026.6.3-cp314-cp314-macosx_11_0_arm64.whl", using: :nounzip
        sha256 "d7469697dce35be237db177d42e2a2ee26e6dcc5fc052078a6fefabd288c6edd"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/b6/36/7fbe9dcdaf857fb3f63c2a2284b62492d95f5e8334e947e5fb6e7f68c9be/rpds_py-2026.6.3-cp314-cp314-macosx_10_12_x86_64.whl", using: :nounzip
        sha256 "931908d9fc855d8f74783377822be318edb6dcb19e47169dc038f9a1bf60b06e"
      end
    end
    on_linux do
      on_arm do
        url "https://files.pythonhosted.org/packages/63/ef/d4cdaf309e6b095b43597103cf8c0b951d6cca2acce68c474f75ec12e0c7/rpds_py-2026.6.3-cp314-cp314-manylinux_2_17_aarch64.manylinux2014_aarch64.whl", using: :nounzip
        sha256 "bcfbcf66006befb9fd2aeaa9e01feaf881b4dc330a02ba07d2322b1c11be7b5d"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/d1/9c/0d1fdc2e7aba23e290d603bc494e97bd205bae262ce33c6b32a69768ed5e/rpds_py-2026.6.3-cp314-cp314-manylinux_2_17_x86_64.manylinux2014_x86_64.whl", using: :nounzip
        sha256 "dc319e5a1de4b6913aac94bf6a2f9e847371e0a140a43dd4991db1a09bc2d504"
      end
    end
  end

  def pythons
    deps.select { |d| d.name.start_with?("python@") }
        .map(&:to_formula)
        .map { |f| (f.opt_libexec/"bin/python").to_s }
  end

  def install
    resource("mathjax").stage do
      (pkgshare/"mathjax").install Dir["es5/*"]
      (pkgshare/"mathjax").install "LICENSE"
    end

    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      site_packages = Language::Python.site_packages(python3)
      private_prefix = libexec/"python#{python_version}"
      resources.each do |r|
        next if r.name == "mathjax"
        next if r.name.start_with?("rpds-py-python") && !r.name.end_with?(python_version.to_s.delete("."))

        r.stage do
          system python3, "-m", "pip", "install", "--no-deps", "--ignore-installed", "--no-compile",
                 "--prefix=#{private_prefix}", Dir["*.whl"].fetch(0)
        end
      end

      private_site = opt_libexec/"python#{python_version}"/site_packages
      # Preserve packages installed in a development venv ahead of this baseline.
      (prefix/site_packages/"sagemath-docbuild-deps.pth").write <<~EOS
        import site, sys; site.addsitedir('#{private_site}'); sys.path.remove('#{private_site}'); sys.path.insert(min((sys.path.index(p) for p in ['#{HOMEBREW_PREFIX/site_packages}', *site.getsitepackages([sys.base_prefix, sys.base_exec_prefix])] if p in sys.path), default=len(sys.path)), '#{private_site}')
      EOS
      (pkgshare/"python#{python_version}-env.sh").write <<~SH
        # Source after activating a Homebrew Python #{python_version} virtual environment.
        source "#{formula_opt_prefix("dimpase/tap/sagemath-deps")}/share/sagemath-deps/python#{python_version}-env.sh"
        export PATH="${VIRTUAL_ENV:+$VIRTUAL_ENV/bin:}#{opt_libexec}/python#{python_version}/bin${PATH:+:$PATH}"
        export JUPYTER_PATH="#{opt_libexec}/python#{python_version}/share/jupyter${JUPYTER_PATH:+:$JUPYTER_PATH}"
        export MATHJAX_DIR="#{opt_pkgshare}/mathjax"
      SH
    end
  end

  def caveats
    <<~EOS
      To build HTML documentation from a Sage checkout, activate a Homebrew Python
      venv created with --system-site-packages, then source the documentation environment:
        source #{opt_pkgshare}/python3.14-env.sh

      This also loads the native build environment from sagemath-deps. Build sagelib
      in the venv first, then run from your Sage checkout:
        python src/build-docs.py --no-pdf-links reference html
        python src/build-docs.py --no-pdf-links tutorial html

      Python 3.13 is also supported on macOS; use python3.13-env.sh for that venv.
      PDF tools and TeX are not included.
    EOS
  end

  test do
    assert_path_exists pkgshare/"mathjax/tex-chtml.js"
    (testpath/"conf.py").write <<~PYTHON
      project = "Sage documentation dependencies"
      html_theme = "furo"
      exclude_patterns = ["venv-*", "html-*", "kernels-*"]
      extensions = ["sphinx_copybutton", "sphinx_inline_tabs", "jupyter_sphinx"]
      jupyter_execute_default_kernel = "docbuild-test"
    PYTHON
    (testpath/"index.rst").write <<~RST
      Documentation dependencies
      ==========================

      .. tab:: Python

         .. code-block:: python

            print(2 + 2)

      .. jupyter-execute::

         print("DOCBUILD_KERNEL_OK", 2 + 2)
    RST

    pythons.each do |python3|
      python_version = Language::Python.major_minor_version(python3)
      site_packages = Language::Python.site_packages(python3)
      private_site = libexec/"python#{python_version}"/site_packages
      venv = testpath/"venv-#{python_version}"
      system python3, "-m", "venv", "--system-site-packages", venv
      kernel_root = testpath/"kernels-#{python_version}"
      (kernel_root/"kernels/docbuild-test/kernel.json").write JSON.generate({
        argv:         ["#{venv}/bin/python", "-m", "ipykernel_launcher", "-f", "{connection_file}"],
        display_name: "Documentation test Python #{python_version}",
        language:     "python",
      })
      packages = resources.map(&:name).reject do |name|
        name == "mathjax" || name.start_with?("rpds-py-python")
      end + ["rpds-py"]
      system venv/"bin/python", "-c", <<~PYTHON
        import importlib.metadata
        import pathlib
        import sys
        assert sys.prefix != sys.base_prefix
        root = pathlib.Path("#{private_site}").resolve()
        for name in #{packages.to_json}:
            dist = importlib.metadata.distribution(name)
            assert pathlib.Path(dist.locate_file("")).resolve() == root, (name, dist.locate_file(""))
        import docutils, furo, jupyter_sphinx, sphinx, sphinx_copybutton, sphinx_inline_tabs
        import nbconvert, nbformat, rpds
        assert sphinx.version_info[:2] == (9, 1)
      PYTHON
      system "bash", "-c", <<~SH
        set -eu
        source "#{venv}/bin/activate"
        source "#{pkgshare}/python#{python_version}-env.sh"
        export JUPYTER_PATH="#{kernel_root}:$JUPYTER_PATH"
        test "$(command -v python)" = "#{venv}/bin/python"
        test -f "$MATHJAX_DIR/tex-chtml.js"
        python -m sphinx -W -b html "#{testpath}" "#{testpath}/html-#{python_version}"
      SH
      assert_match "DOCBUILD_KERNEL_OK", (testpath/"html-#{python_version}/index.html").read
      (venv/site_packages/"sphinx.py").write "VENV_OVERRIDE = True\n"
      system venv/"bin/python", "-c", "import sphinx; assert sphinx.VENV_OVERRIDE"
    end
  end
end
