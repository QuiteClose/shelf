# Shelf

## Shell Utilities
Source the `include/*` files to add the utilities to your shell session. e.g.
Add the following to the end of your `~/.zshrc`:

```
SHELF_PATH=~/example/shelf
for file in $SHELF_PATH/include/*; do
	source $file;
done
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
*   Install packer: https://github.com/wbthomason/packer.nvim
    *   Clone the plugin:
        ```
        git clone --depth 1 https://github.com/wbthomason/packer.nvim\
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim
        ```
    *   Open neovim and run the command:
        ```
        :PackerSync
        ```
*   Install `MesloLGSNerdFontMono-Regular.ttf` (Or some other [Nerd Font](https://github.com/ryanoasis/nerd-fonts/))
*   Install tree-sitter
*   Install CoPilot
