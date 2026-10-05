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
    url "https://files.pythonhosted.org/packages/ec/20/5f5ad4da6a5a27c80f2ed2ee9aee3f9e36c66e56e21c00fde467b2f8f88f/furo-2025.12.19.tar.gz"
    sha256 "188d1f942037d8b37cd3985b955839fea62baa1730087dc29d157677c857e2a7"
  end

  resource "sphinx-basic-ng" do
    url "https://files.pythonhosted.org/packages/98/0b/a866924ded68efec7a1759587a4e478aec7559d8165fac8b2ad1c0e774d6/sphinx_basic_ng-1.0.0b2.tar.gz"
    sha256 "9ec55a47c90c8c002b5960c57492ec3021f5193cb26cebc2dc4ea226848651c9"
  end

  resource "sphinx-copybutton" do
    url "https://files.pythonhosted.org/packages/fc/2b/a964715e7f5295f77509e59309959f4125122d648f86b4fe7d70ca1d882c/sphinx-copybutton-0.5.2.tar.gz"
    sha256 "4cf17c82fb9646d1bc9ca92ac280813a3b605d8c421225fd9913154103ee1fbd"
  end

  resource "sphinx-inline-tabs" do
    url "https://files.pythonhosted.org/packages/76/6a/f39bde46a79b80a9983233d99b773bd24b468bdd9c1e87acb46ff69af441/sphinx_inline_tabs-2025.12.21.14.tar.gz"
    sha256 "c71a75800326e613fb4e410eed92a0934214741326aca9897c18018b9f968cb6"
  end

  resource "accessible-pygments" do
    url "https://files.pythonhosted.org/packages/bc/c1/bbac6a50d02774f91572938964c582fff4270eee73ab822a4aeea4d8b11b/accessible_pygments-0.0.5.tar.gz"
    sha256 "40918d3e6a2b619ad424cb91e556bd3bd8865443d9f22f1dcdf79e33c8046872"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/43/65/318323f98dbee45d42dff61d8f047181bc6f2268a9068cfad035a46be5af/beautifulsoup4-4.15.0.tar.gz"
    sha256 "288e3ca7d54b06f2ac191970bc275c1939cb46d450b255bf6718b04aa37ab4f7"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/69/99/a6ca3beb3ccacb41fb3321d8a60e5566f9e6467601ef8eba6a17e1b89778/soupsieve-2.9.2.tar.gz"
    sha256 "4a55d8cf158a9c2e587fa4922f1bbb91d68ac829e2d6f25403a85747c71daf74"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/f6/cc/6253133b5bb138fc3306cebfbda2c520f545d36b5be2c7255cc528bb45d6/typing_extensions-4.16.0.tar.gz"
    sha256 "dc983d19a509c94dba722ee6abd33940f7c05a89e243c47e907eb4db6f1a43e5"
  end

  def build_documents(python3, documents, format)
    documents.each do |document|
      system python3, "src/build-docs.py", "--no-pdf-links", document, format
    end
  end

  def install
    python3 = formula_opt_libexec("python@3.14")/"bin/python"
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
               *std_pip_args(prefix: extensions, build_isolation: true), "."
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
