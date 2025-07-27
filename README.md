# Shelf

## Ghostty

Config files etc. for Ghostty terminal emulator:

```
mkdir -p ~/.config/ghostty
ln -s ghostty/config ~/.config/ghostty/config
```

## Shell Utilities
Source the `include/*` files to add the utilities to your shell session. e.g.
Add the following to the end of your `~/.zshrc`:

```
source ~/shelf/shelf.sh
```

## NeoVim (Basic)

```bash
ln -s nvim ~/.config/nvim.basic
mkdir ~/.nvimundo
```

## NeoVim IDE Installation
*   Install `MesloLGSNerdFontMono-Regular.ttf` (Or some other [Nerd Font](https://github.com/ryanoasis/nerd-fonts/))
*   Install packages:
    ```bash
    pacman -S cargo composer curl fd go jdk-openjdk julia lua lua-jsregexp lua51 lua51-jsregexp luarocks neovim perl php ruby tree-sitter tree-sitter-cli wget
    ```
*   Link config:
    ```bash
    ln -s nvim ~/.config/nvim
    mkdir ~/.nvimundo
    ```
*   Run `:Lazy` and Sync plugins.
*   Run `:checkhealth` and resolve any issues.
*   Run `:TSInstall all` to update tree-sitter parsers.

