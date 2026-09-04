require "system_command"

class CdaiExternalNodeAT20Requirement < Requirement
  fatal true

  satisfy(build_env: false) do
    compatible_external_node
  end

  def compatible_external_node
    node = which("node")
    return if node.nil? || brewed_node?(node)

    probe = "process.stdout.write('CDAI_NODE_MAJOR=' + process.versions.node.split('.')[0] + '\\n')"
    result = SystemCommand.run(node, args: ["-e", probe], print_stderr: false, timeout: 2)
    match = result.stdout.match(/^CDAI_NODE_MAJOR=(\d+)$/)
    major = match[1].to_i unless match.nil?
    node if result.success? && !major.nil? && major >= 20
  rescue SystemCallError, Timeout::Error
    nil
  end

  def brewed_node?(node)
    node.realpath.to_s.start_with?("#{HOMEBREW_CELLAR}/")
  rescue SystemCallError
    false
  end

  def message
    "cdai requires an active external Node.js 20+ on PATH."
  end

  def display_s
    "external Node.js >= 20"
  end
end

class Cdai < Formula
  desc "Change directories by intent with indexed search and optional AI"
  homepage "https://github.com/franzenzenhofer/cdai"
  url "https://github.com/franzenzenhofer/cdai/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "20cdd3b5a4430710d52dbeab26d3b4ba38b2da7a12cba5fd62899a949a3d6b87"
  license "MIT"
  head "https://github.com/franzenzenhofer/cdai.git", branch: "main"

  node_requirement = CdaiExternalNodeAT20Requirement.new
  if node_requirement.satisfied?
    depends_on CdaiExternalNodeAT20Requirement
  else
    depends_on "node"
  end

  def install
    libexec.install "package.json"
    (libexec/"dist").install "dist/cdai.js"

    external_node = CdaiExternalNodeAT20Requirement.new.compatible_external_node
    preferred_node = external_node || (HOMEBREW_PREFIX/"opt/node/bin/node")
    brew_node = HOMEBREW_PREFIX/"opt/node/bin/node"

    (bin/"cdai").write <<~SH
      #!/bin/sh
      compatible_node() {
        [ -n "$1" ] && [ -x "$1" ] || return 1
        node_major="$("$1" -p "'CDAI_NODE_MAJOR=' + process.versions.node.split('.')[0]" 2>/dev/null)" || return 1
        case "$node_major" in
          CDAI_NODE_MAJOR=2[0-9]|CDAI_NODE_MAJOR=[3-9][0-9]|CDAI_NODE_MAJOR=[1-9][0-9][0-9]*) return 0 ;;
          *) return 1 ;;
        esac
      }

      node_bin=#{preferred_node.to_s.shellescape}
      if [ ! -x "$node_bin" ]; then
        path_node="$(command -v node 2>/dev/null)"
        if compatible_node "$path_node"; then
          node_bin="$path_node"
        elif compatible_node #{brew_node.to_s.shellescape}; then
          node_bin=#{brew_node.to_s.shellescape}
        else
          node_bin=""
        fi
      fi
      if [ -z "$node_bin" ]; then
        echo "cdai: Node.js 20+ is required but no compatible runtime was found." >&2
        echo "Reinstall cdai, or activate Node 20+ and reinstall to pin that runtime." >&2
        exit 1
      fi

      exec "$node_bin" "#{opt_libexec}/dist/cdai.js" "$@"
    SH
  end

  def caveats
    <<~EOS
      cdai reuses an active external Node.js 20+ on PATH. Otherwise Homebrew
      uses its existing Node formula or installs it when needed.

      Enable cdai in your shell, then restart it:

        zsh:  echo 'eval "$(cdai init zsh)"' >> ~/.zshrc
        bash: echo 'eval "$(cdai init bash)"' >> ~/.bashrc
        fish: echo 'cdai init fish | source' >> ~/.config/fish/config.fish

      Finish setup with:

        cdai setup
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/cdai --version 2>&1").strip
    assert_match "cdai - cd with intent", shell_output("#{bin}/cdai --help 2>&1")
    assert_match "# cdai shell integration (zsh)", shell_output("#{bin}/cdai init zsh")
  end
end
