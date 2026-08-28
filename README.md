# dotfiles

Personal configuration files, stowed into `~/.config`.

## Bootstrap

```sh
paru -S mise stow        # macOS: brew install mise stow
git clone git@github.com:afrigon/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
mise trust
mise run bootstrap
exec fish
```

## Tasks

- `mise run setup` — stow config into `~/.config`
- `mise run bootstrap` — setup, then install tools with mise
- `mise run herdr-integration` — install the herdr hook for Claude Code, once per machine
