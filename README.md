# Homebrew tap for cdai

Install [cdai](https://github.com/franzenzenhofer/cdai)—`cd` with indexed search, remembered
intent, smart Tab completion and an optional guarded AI fallback—with one command:

```bash
brew install franzenzenhofer/tap/cdai
```

Homebrew installs the Node runtime dependency automatically. After installation, follow the
printed shell-integration instructions and run:

```bash
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
