# vimfiles
Note: This config is intended for use on Windows and Linux. If using Nix or NixOS, the configuration files in the nix folder are used instead.

## Installation/setup on Windows using neovim

1. Clone the repository into $HOME\vimfiles.

2. Set up symlink to _vimrc file. I did that with the following three command (executed from an administrator access command prompt in the home folder):
```powershell
mklink /H _vimrc vimfiles\_vimrc
```


3. Make neovim use the correct vimrc. Create or append to file 
```
~\AppData\Local\nvim\init.vim
```
the following lines
```
set runtimepath^=~/vimfiles runtimepath+=~/vimfiles/after
let &packpath = &runtimepath
source ~/vimfiles/_vimrc
```
as described in [Neovim docs](https://neovim.io/doc/user/nvim.html#nvim-from-vim)

4. Install vim-plug plugin manager. Following the neovim install instructions [here](https://github.com/junegunn/vim-plug/blob/0c5f0b0528a8d7b9ced56b8f177e98f0ba4d7153/README.md#neovim), run the following in a PowerShell:
```powershell
md ~\AppData\Local\nvim\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\AppData\Local\nvim\autoload\plug.vim"))
```

5. To install plugins, by running vim and executing the command:
```
:PlugInstall
```
Note: Node needs to be installed for coc.nvim extension to work.

## Install on Ubunutu

1. Install neovim

2. Add symlink to vimrc
```
mkdir ~/.config/nvim
ln -s ~/vimfiles/_vimrc ~/.config/nvim/init.vim
```

## Optional: nvim-qt GUI config
1. If you want to use terminal tabs instead of Qt based tabs in nvim-qt, create or append to file 
```
~\AppData\Local\nvim\ginit.vim
```
the following line
```
GuiTabline 0
```

2. If you want to use terminal popup menu instead of Qt based menu in nvim-qt, create or append to file 
```
~\AppData\Local\nvim\ginit.vim
```
the following line
```
GuiPopupmenu 0
```

## Additional dependencies

0. node required for coc extension. Install using node verion manager (nvm) or
```
choco install nodejs
```

1. Preferred font [Consolas NF](https://github.com/whitecolor/my-nerd-fonts/tree/master/Consolas%20NF)

2. For coc-fzf
```
choco install fzf 
```

3. For colors in coc-fzf window
```
choco install bat
```

4. For grepping with ripgrep (rg)
```
choco install ripgrep
```

## Useful commands

### vim-startify
#### Help
```
:h startify
:h startify-faq
```

#### Commands
```vim
:SLoad       "load a session
:SSave[!]    "save a session
:SDelete[!]  "delete a session
:SClose      "close a session
```

### nvim-qt
```vim
:GuiFont                  " get current font
:GuiFont Consolas:h12:b   " set font, font height, and font style (l: light, b: bold, i: italics)
```

