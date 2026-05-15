# brettenv

All the files defining a standard command-line environment, including an initialization script to
get it up and running very quickly.

# Installation

From your home directory:
```bash
  git clone https://github.com/YOUR_USERNAME/brettenv.git .brettenv
  cd .brettenv
```

Then, if you want *all* of my homebrew packages installed on your machine, sample `.local` files
stored in your home directory, and all my config files symlinked into your home directory:

```
  ./install.sh
```

If you'd rather pick and choose from my configurations for various utilities, list the "stow"
directory and then:

```
  brew install stow
  stow -v -d stow -t ~ [stow subdirectory names]
```

# Description

I think what's most interesting about my dotfile setup is my configurations for karabiner, tmux, and
neovim, all of which I've developed over years and modernized recently. Working on a Mac with an
unusual keyboard, I wanted quick, two-hand access to the ctrl and opt keys, so I assigned them to
two-finger combinations on the bottom row in both hands. From there, I built out a paradigm where
ctrl is for tmux shortcuts, opt (meta) and leader key (comma) are for neovim shortcuts, and cmd+opt
is for the Mac GUI outside of the terminal, as much as possible. I now find it efficient and
comfortable for my tendinitis-ridden hands.

The other interesting thing is my Gemini setup. Working with Gemini as my command-line development
partner for a good number of months has led me to wanting it to behave in ways that I find most
useful and to avoid those behaviors that I find annoying. So I've developed a robust collection of
core instructions that it always reads, as well as very specific custom commands for behaviors I
want it to adopt, including a sequence of standard roles that I have Gemini occupy throughout the
development lifecycle.

This repository also includes a collection of shortcut aliases and scripts. My preferred shell is
**zsh**, but I've included bash config as well. I prefer succinct commands (3ish characters) for
common tasks. See the `aliases` file or the scripts in `bin/` for examples.

Some of this, including sending correct ctrl+some_key keycodes to tmux, relies on global keymappings
in karabiner. You can certainly pick individual packages and use my configurations for them, but to
get some of the slickest stuff, you'll need to install and run karabiner and then enable the
keymapping rules you want in the `complex modifications` area of the karabiner settings. 

# Usage

This project uses **GNU Stow** to manage dotfiles. Instead of manually symlinking files or using a
complex initialization script that modifies your existing shell config, Stow creates symlinks from
the `stow/` directory in this repo to your home directory. The following commands must be run from
`~/.brettenv`:

- **`./install.sh`**:
  - Only if you want *everything*.
  - Installs Homebrew and dependencies from `Brewfile`.
  - Creates local configuration templates (`~/.gitconfig.local`, etc.) from `examples/*.example`.
  - Backs up existing conflicting files in your home directory to `.devinfo/backups/`.
  - Uses `stow` to symlink configurations for Zsh, Bash, Tmux, Neovim, and more.
- **`stow -v -d stow -t ~ some_stow_package`**:
  - For picking and choosing stow packages instead of getting them all with install.sh.
  - Symlinks config files from `~/.brettenv/stow/some_stow_package` into your home directory (the `~`).
- **`stow -D -v -d stow -t ~ gemini`**:
  - Removes the symlinks for the config files in `some_stow_package`.
- **`./uninstall.sh`**:
  - Removes all symlinks created by `stow`.
  - Cleans up unmodified local configuration templates.

Don't forget `(mac menu bar) Karabiner > Settings > Complex Modifications` if you want my ctrl, opt
(meta), escape, function-key, tmux ctrl+some_key, etc. keymappings, as well as app and app-window
launchers.

To familiarize yourself with my keyboard shortcuts, look in these files and directories:
- `stow/karabiner/.config/karabiner/assets/complex_modifications/`
- `stow/tmux/.tmux.conf`
- `stow/nvim/.config/nvim/lua/config/keymaps.lua`
- `aliases`

To see my Gemini instructions and commands, look in these:
- `stow/gemini/.gemini/GEMINI.md`
- `stow/gemini/.gemini/commands/`

To familiarize yourself with general conveniences I've set up for myself, look in these:
- `env_vars`
- `stow/tmux/.tmux.conf`
- `stow/nvim/.config/nvim/lua/config/options.lua`
- `stow/nvim/.config/nvim/lua/config/plugins.lua`
- `bin/`

For theming the command-line prompt:
- `stow/starship/.config/starship.toml`
  - Pick a palette from the palettes list below by changing the value of the `palette` variable.
  - Define the format with the `format` variable.
  - Various other settings down below. Look up Starship documentation.

For theming neovim:
- `stow/nvim/.config/nvim/lua/config/themes.lua`
  - Comment out the line of the current theme.
  - Uncomment the line of whatever theme you want to try.
  - Restart neovim.
  - (possibly needed) Type `:Lazy` and hit enter. Type `U`. Maybe restart again.

# Local Configuration

To keep this repo portable and shareable, personal identities and machine-specific settings are
stored in `.local` files that are not tracked by git:
- `~/.gitconfig.local`: Your name and email for Git.
- `~/.secrets.local`: API keys, tokens, and sensitive exports.
- `~/.zshrc.local`: Machine-specific Zsh aliases or functions.

Templates for these are provided in the `examples/` directory.

# Root User

Since root can usually read anything on the filesystem, you can run the `install.sh` script from
root's home directory pointing to this installation to set up the root environment similarly.

# Other Users

If you want some other non-root user to have access to this installation, you'd just need to give
them read access to the directory and have them run the `install.sh` script (or manually `stow` the
packages they want).
