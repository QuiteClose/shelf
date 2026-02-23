# Shelf

Shell functions and editor config. Source a single file to get project navigation, git helpers, timestamped notes, and more.

## Quick Start

```bash
git clone git@github.com:QuiteClose/shelf.git ~/opt/shelf
cd ~/opt/shelf
./build.sh > ./shelf.sh
echo "source ~/opt/shelf/shelf.sh" >> ~/.zshrc
```

## Shell Functions

### `workspace` -- project workspaces

Create, search, and switch between timestamped project directories.

```
workspace              # switch to most recent workspace
workspace foo          # search for "foo", cd if one match
workspace -c myproj    # create ~/workspaces/myproj.260222
workspace -d foo       # search, sorted by date
```

### `repo` -- git repositories

Clone, search, and navigate a structured repo tree (`~/repos/<remote>/<owner>/<repo>`).

```
repo shelf             # search for "shelf", cd if one match
repo --clone git@github.com:QuiteClose/shelf.git
repo -b                # browse all remotes
repo -g python         # search, sorted by git activity
```

### `tempdir` -- temporary directories

Create and search disposable working directories with a date prefix.

```
tempdir -c             # create a new tempdir and cd into it
tempdir foo            # search tempdirs for "foo"
tempdir -p             # prune empty tempdirs older than 7 days
tempdir -t             # tree view
```

### `shoes` -- cluster login manager

Manage a Vault token and cluster login files.

```
shoes prod             # source a matching cluster file
shoes -t               # source the Vault token
shoes -c staging       # create a new cluster file
shoes -e               # edit the token file
shoes -s               # list all cluster files
```

### `ts` / `tsl` -- timestamp logging

Record timestamped notes to `timestamps.txt` in the current directory. `tsl` converts UTC timestamps to local time (macOS only).

```
ts started the migration      # log a message
ts                             # show timestamps
ts -                           # add notes to the last entry
ts --all                       # show timestamps with notes
```

### `git-go`, `git-scrub`, `git-strip` -- git helpers

```
git-go                         # cd to the root of the current git project
git-scrub                      # delete branches already merged into main/master
git-strip file.py              # strip trailing whitespace
git-strip --since HEAD~3       # strip whitespace from recently changed files
```

### `k` -- kubectl alias

Shorthand for `kubectl`.

### `activate` -- venv shortcut

Alias for `source ./venv/bin/activate`.

## Environment Variables

Shell functions use sensible defaults but can be overridden:

| Variable | Default | Used by |
| --- | --- | --- |
| `SHELF_REPOS` | `~/repos` | `repo` |
| `SHELF_WORKSPACES` | `~/workspaces` | `workspace` |
| `SHELF_TEMPDIRS` | `~/tempdirs` | `tempdir` |
| `SHELF_SHOES` | `~/.local/share/shoes` | `shoes` |
| `DAISY_ROOT` | `~/.daisy` | neovim todotxt plugin |
| `EDITOR` | `vi` | `shoes` (edit/create) |

## Prerequisites

- **zsh** -- all shell functions assume zsh
- **GNU coreutils** -- required on macOS (see below)
- **tree** -- used by `repo -b` and `tempdir -t`

### macOS: GNU coreutils

Several functions rely on GNU `stat`, `find`, `sed`, `grep`, and `awk`. Install and prepend to `$PATH`:

```bash
brew install coreutils findutils gawk gnu-sed grep
```

```bash
# Add to ~/.zshrc (Apple Silicon):
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# Intel Macs: replace /opt/homebrew with /usr/local
```

## Ghostty

Config for the [Ghostty](https://ghostty.org) terminal emulator.

```bash
# Linux:
ln -s ~/opt/shelf/ghostty/config ~/.config/ghostty/config

# macOS:
ln -s ~/opt/shelf/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

## Neovim

### Basic config (no plugins)

```bash
mkdir -p ~/.config/nvim/lua
ln -sf ~/opt/shelf/nvim/basic.lua     ~/.config/nvim/init.lua
ln -sf ~/opt/shelf/nvim/lua/quiteclose ~/.config/nvim/lua/quiteclose
```

### Full IDE config

1. Install a [Nerd Font](https://github.com/ryanoasis/nerd-fonts/) (e.g. MesloLGS Nerd Font Mono).
2. Set up the basic config above.
3. Install language toolchains:

    **Arch Linux:**
    ```bash
    pacman -S cargo composer curl fd go jdk-openjdk julia lua \
      lua-jsregexp lua51 lua51-jsregexp luarocks neovim perl php ruby \
      tree-sitter tree-sitter-cli wget
    ```

    **macOS:**
    ```bash
    brew install composer curl fd go julia lua luajit luarocks \
      openjdk neovim perl php python3 ripgrep ruby rust tree-sitter wget
    ```
    Then build lua 5.1 from source (not available via Homebrew):
    ```bash
    pushd $(mktemp -d)
    curl -O https://www.lua.org/ftp/lua-5.1.5.tar.gz
    tar xzf lua-5.1.5.tar.gz
    cd lua-5.1.5
    make macosx
    make INSTALL_TOP=$HOME/opt/lua@5.1 install
    ln -s ~/opt/lua@5.1/bin/lua ~/bin/lua5.1
    popd
    ```

4. Get `:checkhealth` passing inside `nvim`.

5. Link the plugin config:

```bash
ln -sf ~/opt/shelf/nvim/init.lua    ~/.config/nvim/init.lua
ln -sf ~/opt/shelf/nvim/lua/plugins ~/.config/nvim/lua/plugins
```

6. Open `nvim`, run `:Lazy` and sync, then `:TSInstall all`.
7. Run `:checkhealth` and resolve any issues.

## License

[Unlicense](LICENSE) -- public domain.
