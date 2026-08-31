class Cdai < Formula
  desc "Change directories by intent with indexed search and optional AI"
  homepage "https://github.com/franzenzenhofer/cdai"
  url "https://github.com/franzenzenhofer/cdai/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "cc15e1fea0171a8073c7686eb46fbea12b6904378bb1c0890b3ae045238bb645"
  license "MIT"
  revision 1
  head "https://github.com/franzenzenhofer/cdai.git", branch: "main"

  depends_on "node" => :test

  def install
    libexec.install "package.json"
    (libexec/"dist").install "dist/cdai.js"

    (bin/"cdai").write <<~SH
      #!/bin/sh
      node_bin="$(command -v node 2>/dev/null)"
      if [ -z "$node_bin" ]; then
        echo "cdai: Node.js 20+ is required on PATH." >&2
        echo "Install it with your existing version manager (nvm, fnm, asdf, Volta or mise)." >&2
        exit 1
      fi

      node_version="$($node_bin -p 'process.versions.node' 2>/dev/null)"
      node_major="${node_version%%.*}"
      case "$node_major" in
        ''|*[!0-9]*) node_major=0 ;;
      esac
      if [ "$node_major" -lt 20 ]; then
        echo "cdai: Node.js 20+ is required; found ${node_version:-unknown}." >&2
        echo "Upgrade Node with your existing version manager." >&2
        exit 1
      fi

      exec "$node_bin" "#{opt_libexec}/dist/cdai.js" "$@"
    SH
  end

  def caveats
    <<~EOS
      cdai requires Node.js 20+ on PATH. This formula deliberately reuses
      your existing nvm, fnm, asdf, Volta, mise or system Node installation.

      Enable cdai in your shell, then restart it:

        zsh:  echo 'eval "$(cdai init zsh)"' >> ~/.zshrc
        bash: echo 'eval "$(cdai init bash)"' >> ~/.bashrc
        fish: echo 'cdai init fish | source' >> ~/.config/fish/config.fish

      Finish setup with:

        cdai setup
    EOS
  end

  test do
    assert_operator Version.new(shell_output("node --version").strip.delete_prefix("v")), :>=, Version.new("20")
    assert_equal version.to_s, shell_output("#{bin}/cdai --version 2>&1").strip
    assert_match "cdai - cd with intent", shell_output("#{bin}/cdai --help 2>&1")
    assert_match "# cdai shell integration (zsh)", shell_output("#{bin}/cdai init zsh")
  end
end
