# Homebrew tap for cdai

Install [cdai](https://github.com/franzenzenhofer/cdai)—`cd` with indexed search, remembered
intent, smart Tab completion and an optional guarded AI fallback—with one command:

```bash
brew install franzenzenhofer/tap/cdai
```

Requires Node.js 20+. Homebrew reuses an active compatible Node on `PATH`, including one activated
by nvm, fnm, asdf, Volta or mise. Otherwise it uses an already-installed Homebrew Node or installs
one automatically.

Enable cdai in your shell:

```bash
# zsh
echo 'eval "$(cdai init zsh)"' >> ~/.zshrc

# Bash
echo 'eval "$(cdai init bash)"' >> ~/.bashrc

# Fish
echo 'cdai init fish | source' >> ~/.config/fish/config.fish
```

Then start a new shell and finish setup:

```bash
exec "$SHELL"
cdai setup
cdai doctor
```

## Brewfile

```ruby
tap "franzenzenhofer/tap"
brew "cdai"
```

## Updates

```bash
brew update
brew upgrade cdai
```

Usage, shell setup and safety details live in the
[cdai README](https://github.com/franzenzenhofer/cdai#readme).
