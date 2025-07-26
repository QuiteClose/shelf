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

## NeoVim

```bash
ln -s nvim ~/.config/nvim
mkdir ~/.nvimundo
```

## NeoVim IDE Installation
*   Install neovim
*   Clone repo & link:
    ```bash
    ln -s nvim ~/.config/nvim
    mkdir ~/.nvimundo
    ```
*   Install `MesloLGSNerdFontMono-Regular.ttf` (Or some other [Nerd Font](https://github.com/ryanoasis/nerd-fonts/))
*   Install tree-sitter
*   Install CoPilot
