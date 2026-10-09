class Bigarrow < Formula
  desc "Point at things on the macOS screen with a big arrow and a sign, for AI agents"
  homepage "https://github.com/franzenzenhofer/big-arrow-on-the-screen"
  url "https://github.com/franzenzenhofer/big-arrow-on-the-screen/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "c9ffb708125a7b14a5c88bf1d6b43b26f7ef28afae99079632126ca93e892b27"
  license "MIT"
  head "https://github.com/franzenzenhofer/big-arrow-on-the-screen.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/bigarrow"
    (pkgshare/"skill").install "skill/big-arrow"
  end

  def caveats
    <<~EOS
      Install the agent skill for Claude Code and Codex:
        bigarrow install-skill

      Drawing needs no permission. Pointing at a UI element by its label (--element) needs
      Accessibility for the app that runs your shell; `bigarrow doctor` names it.
    EOS
  end

  test do
    assert_equal "bigarrow #{version}", shell_output("#{bin}/bigarrow --version").strip
    assert_match "\"drawingNeedsPermission\":false", shell_output("#{bin}/bigarrow doctor --json")
    assert_match "is not one of", shell_output("#{bin}/bigarrow point --at 1,1 --text x --size XL 2>&1", 2)
    assert_path_exists pkgshare/"skill/big-arrow/SKILL.md"
  end
end
