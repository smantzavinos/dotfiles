# dotfiles

## tmux
Create symlink to tmux config
```
cd ~
ln -s dotfiles/.tmux.conf .tmux.conf
```

## fish
Symlink to fish config and the plugins
```
cd ~
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins
```
NOTE: Not using the full path can fail to create the correct symlink. It is therefore important to use the "~/" at the start of the path in the ln command. This gets expanded by the shell to the full path.

Install (fisher plugin)[https://github.com/jorgebucaran/fisher]. Run fisher update to install plugins listed in fish_plugins.
```
fisher update
```
