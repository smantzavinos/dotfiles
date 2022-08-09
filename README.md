# dotfiles

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

Install (fisher plugin)[https://github.com/jorgebucaran/fisher]. Run fisher update to install plugins listed in fish_plugins.
```
fisher update
```

## emacs

Install the preferred font: [Consolas NF](https://github.com/whitecolor/my-nerd-fonts/tree/master/Consolas%20NF)

Copy the `.emacs.d/init_local.el` file from this repo to `~/.emacs.d/init.el` and configure the values for the local system paths.

