class SagemathDoc < Formula
  desc "HTML documentation for SageMath"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta1.tar.gz"
  sha256 "fc3e2af93024456c3898243a49dcfa721292b85f264c4c3a94c2ed22d3385091"
  license "GPL-2.0-or-later"

  depends_on "python@3.14" => :build
  depends_on "sphinx-doc" => :build
  depends_on "dimpase/tap/sagemath"

  resource "furo" do
    url "https://files.pythonhosted.org/packages/f4/b2/50e9b292b5cac13e9e81272c7171301abc753a60460d21505b606e15cf21/furo-2025.12.19-py3-none-any.whl", using: :nounzip
    sha256 "bb0ead5309f9500130665a26bee87693c41ce4dbdff864dbfb6b0dae4673d24f"
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

  resource "accessible-pygments" do
    url "https://files.pythonhosted.org/packages/8d/3f/95338030883d8c8b91223b4e21744b04d11b161a3ef117295d8241f50ab4/accessible_pygments-0.0.5-py3-none-any.whl", using: :nounzip
    sha256 "88ae3211e68a1d0b011504b2ffc1691feafce124b845bd072ab6f9f66f34d4b7"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/88/c6/92fcd42f1ba33e1184263f25bfabf3d27c383410470f169e4b8163bf9c17/beautifulsoup4-4.15.0-py3-none-any.whl", using: :nounzip
    sha256 "d6f88de62e1d4e38ecb1077eb9724cd0eff29d2a08ca16a401e9b9e93f117cf9"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/eb/dc/ad025c1ee131eba60c69f4dd5779b18fcf1e6b21a343e2162a84d5d133c7/soupsieve-2.9.2-py3-none-any.whl", using: :nounzip
    sha256 "8089a26fd974ca7a1f30276d3d8492ab266ab15af581642dfe8aa162e0c1c823"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/49/d3/b8441a820a491ddfc024b0b0cf0393375b75ea13866d9c66727e54c2fc80/typing_extensions-4.16.0-py3-none-any.whl", using: :nounzip
    sha256 "481caa481374e813c1b176ada14e97f1f67a4539ce9cfeb3f350d78d6370c2e8"
  end

  def build_documents(python3, documents, format)
    documents.each do |document|
      system python3, "src/build-docs.py", "--no-pdf-links", document, format
    end
  end

  def install
    python3 = (formula_opt_libexec("python@3.14")/"bin/python").to_s
    site_packages = Language::Python.site_packages(python3)
    extensions = buildpath/"doc-extensions"
    ENV["PYTHONPATH"] = "#{extensions/site_packages}:#{formula_opt_libexec("sphinx-doc")/site_packages}"
    ENV["SAGE_ROOT"] = buildpath
    ENV["SAGE_SRC"] = buildpath/"src"
    ENV["SAGE_DOC_SRC"] = buildpath/"src/doc"
    ENV["SAGE_DOC"] = share/"doc/sage"
    ENV["SAGE_NUM_THREADS"] = ENV.make_jobs.to_s
    # Sage docbuild forks workers after importing macOS framework libraries.
    ENV["OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES" if OS.mac?
    ENV["DOT_SAGE"] = buildpath/"dot-sage"

    # Sphinx and its dependencies come from sphinx-doc; only Sage's additional
    # theme/extensions are installed into a temporary build prefix.
    resources.each do |r|
      r.stage do
        system python3, "-m", "pip", "install",
               "--no-deps", "--ignore-installed", "--no-compile",
               "--prefix=#{extensions}", Dir["*.whl"].fetch(0)
      end
    end
    documents = Utils.safe_popen_read(python3, "src/build-docs.py", "--all-documents", "all")
                     .lines.map(&:strip)
    # Build inventories before HTML so manuals can resolve cross-references.
    build_documents(python3, ["reference"] + documents, "inventory")
    build_documents(python3, ["reference"] + documents, "html")

    # Keep rendered HTML; inventories and doctrees are build intermediates.
    %w[doctrees inventory].each do |directory|
      rm_r(share/"doc/sage"/directory) if (share/"doc/sage"/directory).exist?
    end
  end

  test do
    assert_path_exists share/"doc/sage/html/en/tutorial/index.html"
    assert_path_exists share/"doc/sage/html/en/reference/index.html"
    assert_match "Sage", (share/"doc/sage/html/en/tutorial/index.html").read
  end
end
