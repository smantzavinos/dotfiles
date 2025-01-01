# Current dotfiles usage

## NixOS

1) Install NixOS from a bootable USB installer.
2) copy ssh keys on to computer
3) Install git and vim (use nano to add to `/etc/nixos/configuration.nix` and rebuild)
4) clone this repo
```
cd ~
git clone git@github.com:smantzavinos/dotfiles.git
```

## Windows

# Archived
## tmux
Create symlink to tmux config
```
cd ~
ln -s dotfiles/.tmux.conf .tmux.conf
```
Reload new config file (ctrl-b is default tmux prefix)
```
:source-file ~/.tmux.conf
```

## fish
Symlink to fish config and the plugins
```
cd ~
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins
```
NOTE: Not using the full path can fail to create the correct symlink. It is therefore important to use the "~/" at the start of the path in the ln command. This gets expanded by the shell to the full path.

Load new fish config with:
```
source ~/.config/fish/config.fish
```

Install [fisher plugin](https://github.com/jorgebucaran/fisher). Run fisher update to install plugins listed in fish_plugins.
```
fisher update
```

## emacs

Copy the `.emacs.d/init_local.el` file from this repo to `~/.emacs.d/init.el` and configure the values for the local system paths.

### Fonts
Install the preferred font: [Consolas NF](https://github.com/whitecolor/my-nerd-fonts/tree/master/Consolas%20NF). 
Update: I now prefer [JetBrains Mono](https://www.jetbrains.com/lp/mono/). 
(Ubunutu font install: Copy the font to the `~/.fonts` directory)

To get additional icons working I also had to execute `all-the-icons-install-fonts` and `nerd-icons-install-fonts` command and manually install the fonts it downloaded (it asks you where to save the downloaded fonts).

For variable width fonts, install (ET Bembo)[https://github.com/DavidBarts/ET_Bembo] Font.

### Dependencies
ripgrep
fd
gnuplot
graphviz
plantuml

### Enabling emacs auto-commit

#### As a file-local variable

Set a file local variable (requires Emacs 24 or newer)
```
;; -*- eval: (git-auto-commit-mode 1) -*-
```

#### As a directory-local variable

Create a ~.dir-locals.el~ file in the directory where you want
git-auto-commit-mode to be enabled. This will also apply to any
subdirectories, so be careful. For more information see the [[https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html#Directory-Variables][Per-Directory
Local Variables]] section in the Emacs manual. Then put one of the following
snippets of code in there:

(requires Emacs 24 or newer)
```
((nil . ((eval git-auto-commit-mode 1))))
```


#### As a hook

To enable git-auto-commit-mode each time a ~certain-hook~ runs:
```
(add-hook 'certain-hook 'git-auto-commit-mode)
```


# OS Config
## Remap caps lock to control
### Windows
Run the `Windows\remap_caps_to_ctrl.reg` regisrty editor script.

Windows PowerToys can be used to do this as well, but I have found the registry editor script to be more reliable.

### Ubuntu
Install gnome-tweak-tool
``` bash
sudo apt install gnome-tweaks
```
Launch Tweaks
Keyboard & Mouse -> Additional Layout Options -> Caps Lock behavior -> Make Caps Lock and additional Ctrl

