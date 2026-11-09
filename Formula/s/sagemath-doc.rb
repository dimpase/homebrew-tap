class SagemathDoc < Formula
  desc "HTML documentation for SageMath"
  homepage "https://www.sagemath.org"
  url "https://github.com/sagemath/sage/archive/refs/tags/11.0.beta6.tar.gz"
  sha256 "bb767ddc886d29f036ba56b8a92e238e316b37baa5b3f96fc6d2f9108a1827e1"
  license "GPL-2.0-or-later"

  depends_on "dimpase/tap/sagemath-docbuild-deps" => :build
  depends_on "python@3.14" => :build
  depends_on "dimpase/tap/sagemath"

  def install
    python3 = (formula_opt_libexec("python@3.14")/"bin/python").to_s
    site_packages = Language::Python.site_packages(python3)
    docdeps = formula_opt_libexec("dimpase/tap/sagemath-docbuild-deps")/"python3.14"
    runtime_site = formula_opt_prefix("dimpase/tap/sagemath")/site_packages
    ENV["PYTHONPATH"] = "#{docdeps/site_packages}:#{runtime_site}"
    ENV["PYTHONNOUSERSITE"] = "1"
    ENV.prepend_path "PATH", docdeps/"bin"
    ENV.prepend_path "JUPYTER_PATH", formula_opt_prefix("dimpase/tap/sagemath")/"share/jupyter"
    ENV["SAGE_ROOT"] = buildpath
    ENV["SAGE_SRC"] = buildpath/"src"
    ENV["DOT_SAGE"] = buildpath/"dot-sage"
    ENV["MPLCONFIGDIR"] = buildpath/"matplotlib"
    ENV["SAGE_NUM_THREADS"] = ENV.make_jobs.to_s
    # Sage's documentation builder forks workers after importing macOS frameworks.
    ENV["OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES" if OS.mac?
    # Sphinx resolves this below each manual's _static directory.
    ENV["MATHJAX_DIR"] = "mathjax"

    # Preserve errors from the CLI help subprocess in Homebrew's build log.
    inreplace "src/sage_docbuild/__main__.py",
              "capture_output=capture)", "stdout=subprocess.PIPE if capture else None)"

    system python3, "-c", <<~PYTHON
      import pathlib
      import shutil
      import subprocess
      from importlib.resources import files

      # Sage requires exactly these three lines before initializing libgap.
      systemfile = files("sage").joinpath("ext_data/gap/kernel-info.g")
      gap = subprocess.run(["gap", "--systemfile", systemfile], capture_output=True, text=True)
      assert gap.returncode == 0 and len(gap.stdout.strip().split("\\n")) == 3, (
          shutil.which("gap"), str(systemfile), gap.returncode, gap.stdout, gap.stderr)

      import sage.all
      import sage.version
      import sphinx
      assert sage.version.version == "#{version}", sage.version.version
      assert pathlib.Path(sage.all.__file__).resolve().is_relative_to(pathlib.Path("#{runtime_site}").resolve())
      assert pathlib.Path(sphinx.__file__).resolve().is_relative_to(pathlib.Path("#{docdeps}").resolve())
    PYTHON

    # Meson generates the bibliography before building its inventory.
    references = buildpath/"src/doc/en/reference/references"
    system python3, "src/sage_docbuild/generate-references.py",
           "src/doc/reference-database.rst", references/"index.rst.in", references/"index.rst"

    output = buildpath/"doc-output"
    command = [python3, "src/build-docs.py", "--no-pdf-links", "--no-prune-empty-dirs",
               "--source=#{buildpath}/src/doc", "--output=#{output}"]
    documents = Utils.safe_popen_read(*command, "--all-documents", "all").lines.map(&:strip)
    odie "Sage did not list its documentation sources" unless documents.include?("en/tutorial")

    # Match Meson's inventory dependencies. The direct reference HTML builder
    # checks its inventory pass again, reusing these completed doctrees.
    system(*command, "reference", "inventory")
    %w[en/developer en/installation].each do |document|
      system(*command, document, "inventory")
    end
    ["reference", *documents].each do |document|
      system(*command, document, "html")
    end

    # Install only rendered manuals, retaining their HTML inventories and assets.
    (share/"doc/sage").install output/"html", output/"index.html"
    html_root = share/"doc/sage/html"
    (html_root/"_static").mkpath
    cp_r formula_opt_prefix("dimpase/tap/sagemath-docbuild-deps")/"share/sagemath-docbuild-deps/mathjax",
         html_root/"_static"
    # One shared MathJax tree keeps all manuals usable offline without retaining
    # the documentation build dependencies or duplicating their assets.
    html_root.glob("**/_static").each do |static_dir|
      next if static_dir == html_root/"_static" || static_dir.symlink?

      static_dir.install_symlink html_root/"_static/mathjax" => "mathjax"
    end
  end

  def caveats
    <<~EOS
      The SageMath HTML manuals are installed at:
        #{HOMEBREW_PREFIX}/share/doc/sage/index.html

      Open that file in a browser, or run:
        sage --doc
    EOS
  end

  test do
    assert_path_exists share/"doc/sage/index.html"
    %w[tutorial reference developer installation].each do |manual|
      assert_match version.to_s, (share/"doc/sage/html/en"/manual/"index.html").read
      assert_equal "# Sphinx inventory version 2\n", (share/"doc/sage/html/en"/manual/"objects.inv").open(&:readline)
    end
    assert_path_exists share/"doc/sage/html/fr/tutorial/index.html"
    assert_match 'id="lee2011"', (share/"doc/sage/html/en/reference/references/index.html").read
    system (formula_opt_libexec("python@3.14")/"bin/python").to_s, "-c", <<~PYTHON
      import os
      from html.parser import HTMLParser
      from pathlib import Path
      from urllib.parse import unquote, urlsplit
      os.environ.pop("SAGE_DOC", None)
      from sage.env import SAGE_DOC

      root = Path("#{share}/doc/sage")
      assert (Path(SAGE_DOC) / "html/en/tutorial/index.html").samefile(root / "html/en/tutorial/index.html")
      for path in root.rglob("*"):
          if path.is_symlink():
              assert path.exists(), path
              assert path.resolve().is_relative_to(root), path

      class Scripts(HTMLParser):
          def __init__(self):
              super().__init__()
              self.sources = []

          def handle_starttag(self, tag, attrs):
              if tag == "script" and (source := dict(attrs).get("src")):
                  self.sources.append(source)

      for relative in ("html/en/tutorial/tour_polynomial.html",
                       "html/en/reference/rings_standard/sage/rings/integer.html"):
          page = root / relative
          parser = Scripts()
          parser.feed(page.read_text())
          mathjax = [source for source in parser.sources if "mathjax/tex-chtml.js" in source]
          assert mathjax, page
          for source in mathjax:
              url = urlsplit(source)
              assert not url.scheme and not url.netloc and not url.path.startswith("/"), source
              asset = (page.parent / unquote(url.path)).resolve()
              assert asset.samefile(root / "html/_static/mathjax/tex-chtml.js"), (page, source)
    PYTHON
  end
end
