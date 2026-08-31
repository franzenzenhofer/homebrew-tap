class Cdai < Formula
  desc "Change directories by intent with indexed search and optional AI"
  homepage "https://github.com/franzenzenhofer/cdai"
  url "https://github.com/franzenzenhofer/cdai/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "cc15e1fea0171a8073c7686eb46fbea12b6904378bb1c0890b3ae045238bb645"
  license "MIT"
  head "https://github.com/franzenzenhofer/cdai.git", branch: "main"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec/"bin/cdai"
  end

  def caveats
    <<~EOS
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
