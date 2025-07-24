
# NixOS and Home Manager Configuration

## Overview
This repository contains my personal NixOS and Home Manager configurations.
System configuration is stored as single file that is imported in existing system configuration.
Home environment uses Nix Flakes to ensure reproducible builds and easy
management of system and user-level settings.

## Structure
- /system_shared.nix/: Contains the system-wide NixOS configuration.
- /home.nix/: Holds the user-specific configuration managed by Home Manager.
- /flake.nix/: The central flake file defining inputs and outputs for Home Manager.

### vim
Vim plugins are installed as nixpkgs. Lazy.nvim is used to load packages, but is configured to not auto-install any missing ones.

If there is a plugin that is not available in nixos, you can configure it with Lazy.nvim and install with `:Lazy install` in vim.

## Usage

### Prerequisites
- Nix with Flakes support enabled. See [[Appendix]] for details on setting up NixOS system.

### Install [Home Manager](https://nix-community.github.io/home-manager/index.html)
Run:
``` bash
cd ~/dotfiles/nix/home
nix build .#homeConfigurations.spiros.activationPackage
#+end_src

This will create the file `./result/activate` that can then be executed to install home-manager into the user environment. This is persistent across shells and system reboots.

Install home manager:
#+begin_src bash
./result/activate
```

### Applying Home Manager Configuration
To apply the Home Manager configuration for the user 'spiros', use:
``` bash
home-manager switch --flake .
```

### Clone dotfiles
Can now use GitHub CLI to clone dotfile repos
``` bash
cd ~
gh repo auth login
gh repo clone dotfiles
gh repo clone vimfiles
```
## Appendix
### Setting up NixOS
#### Update NixOS version
See the [NixOS Upgrade Instructions](https://nixos.org/manual/nixos/stable/index.html#sec-upgrading)

Basic steps are:

See what channel you are currently on
``` bash
sudo nix-channel --list | grep nixos
```

Update the channel
``` bash
sudo nix-channel --add https://channels.nixos.org/nixos-23.11 nixos
```

Upgrade with
``` bash
# option 1
sudo nixos-rebuild switch --upgrade

# option 2 (equivalent to option 1)
sudo nix-channel --update nixos
sudo nixos-rebuild switch
```

#### Install git and vim
Edit config to install git and vim.
``` bash
sudo nano /etc/nixos/configuration.nix
```

Install git as shown below
``` bash
users.users.spiros = {
  ...
  packages = with pkgs; [
     ...
    git  # Add this line <------
    ...
  ];
};
```

Run the following command to install git
``` bash
sudo nixos-rebuild switch
```

#### System shared config
clone the dotfiles_nix repo in the home directory.

Edit the system configuration file again to import the shared system configuration file:
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix # add this line <------
  ];
 ...
```
#### System specific config
If the system config also includes a system specific config, include that file as well.
##### Dell Precision T5600
Edit /etc/nixos/configuration.nix
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix
    /home/spiros/dotfiles/nix/systems/precision_t5600.nix # add this line <------
  ];
 ...
```
##### Lenovo X1 Extreme Gen 2
Set up the nixos-hardware channel
``` bash
$ sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
$ sudo nix-channel --update
```

Add [nixos-hardware](https://github.com/NixOS/nixos-hardware) config and system specific config.
The nixos-hardware config correctly installs things like battery settings, screen DPI settings, and trackpad drivers.
The system specific config also sets up nvidia drivers. I'm not sure why the nixos-hardware channel does not configure this. The nvidia drivers are set up for "sync mode". See the [NixOS Nvidia Wiki](https://nixos.wiki/wiki/Nvidia) for more information.
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix
    <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2> # add this line <------
    /home/spiros/dotfiles/nix/systems/lenovo_x1_extreme.nix # add this line <------
  ];
 ...
```

#### Apply system confg
and rebuild NixOS again
``` bash
sudo nixos-rebuild switch
```
#### Set up ssh keys
Copy ssh keys to the system. Either by USB or scp.

Ensure key file permission are restrictive enough (required by ssh agent)
``` bash
chmod 600 ~/.ssh/your_private_key
```

Load the key in to the agent
``` bash
ssh-add ~/.ssh/your_private_key
```

Now ready to follow instructions above to install home manager.
