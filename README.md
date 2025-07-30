# Shelf
Useful shell functions & IDE setup.

## Start
Install the repo:
```
mkdir ~/opt
git clone git@github.com:QuiteClose/shelf.git ~/opt/shelf
```

## Shell Functions
Build the `shelf.sh` script from the `shelf/*.sh` files:
```bash
./build.sh > ./shelf.sh
```
Source the `shelf.sh` file in your `~/.zshrc`:
```
echo "source ~/opt/shelf/shelf.sh" >> ~/.zshrc
```

## Ghostty
Config files etc. for Ghostty terminal emulator.
*   Install on Linux:
    ```
    ln -s ~/opt/shelf/ghostty/config ~/.config/ghostty/config
    ```
*   Install on MacOS:
    ```
    ln -s ~/opt/shelf/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
    ```

## NeoVim (Basic)
```bash
mkdir -p ~/.nvimundo ~/.config/nvim/lua
ln -sf ~/opt/shelf/nvim/basic.lua      ~/.config/nvim/init.lua
ln -sf ~/opt/shelf/nvim/lua/quiteclose ~/.config/nvim/lua/quiteclose
```

## NeoVim IDE Installation
*   Install `MesloLGSNerdFontMono-Regular.ttf` (Or some other [Nerd Font](https://github.com/ryanoasis/nerd-fonts/))
*   Setup basic config:
    ```bash
    mkdir -p ~/.nvimundo ~/.config/nvim/lua
    ln -sf ~/opt/shelf/nvim/basic.lua      ~/.config/nvim/init.lua
    ln -sf ~/opt/shelf/nvim/lua/quiteclose ~/.config/nvim/lua/quiteclose
    ```
*   Install required packages:
    *   On Linux:
        ```bash
        pacman -S cargo composer curl fd go jdk-openjdk julia lua lua-jsregexp lua51 lua51-jsregexp luarocks neovim perl php ruby tree-sitter tree-sitter-cli wget
        ```
    *   On MacOS:
        1.  Install available packages:
            ```bash
            brew install composer curl fd go julia lua luajit luarocks openjdk neovim perl php python3 rip-grep ruby rust tree-sitter wget
            ```
        0.  Build `lua5.1` from source:
            ```
            pushd $(mktemp -d)
            curl -O https://www.lua.org/ftp/lua-5.1.5.tar.gz
            tar xzf lua-5.1.5.tar.gz
            cd lua-5.1.5
            make macosx
            mkdir ~/opt
            make INSTALL_TOP=$HOME/opt/lua@5.1 install
            ln -s ~/opt/lua@5.1/bin/lua ~/bin/lua5.1
            popd
            ```
*   Get `:checkhealth` passing inside `nvim`
*   Link plugin config:
    ```bash
    ln -sf ~/opt/shelf/nvim/init.lua    ~/.config/nvim/init.lua
    ln -sf ~/opt/shelf/nvim/lua/plugins ~/.config/nvim/lua/plugins
    ```
*   Run `:Lazy` and Sync plugins.
*   Run `:checkhealth` and resolve any issues.
*   Run `:TSInstall all` to update tree-sitter parsers.
*   Run `:checkhealth` and resolve any issues.
