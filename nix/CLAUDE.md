# NixOS Dotfiles Guidelines

## Build/Test Commands
- `nixos-rebuild switch --flake .#<hostname>` - Apply full system configuration (includes home-manager)
- `home-manager switch --flake .#<hostname>` - Apply only Home Manager configuration independently
- `nix run github:nix-community/home-manager/release-24.11 -- switch --flake .#<hostname>` - Run home-manager without installing it
- `nix build .#homeConfigurations.<hostname>.activationPackage` - Build home-manager config
- `nix flake update` - Update flake dependencies
- `nixfmt flake.nix` - Format Nix files

Available hostnames: nixos, x1, t5600, t7910, msi_gs66, msi_ms16, vbox

## Notes
- The `home-manager` CLI is installed system-wide, so you can use `home-manager switch --flake .#<hostname>` directly after a system rebuild

## Code Style Guidelines
- **Indentation**: Use 2-space indentation consistently across all file types
- **Imports**: Group by purpose (nixpkgs, home-manager, etc.), use descriptive names
- **File Organization**: System configs in `/systems/`, home configs in `/home/`
- **Naming**: Use descriptive variable names, kebab-case for file names, camelCase for variables
- **Feature Flags**: Use the `flags` system for conditionally enabling features
- **Neovim Config**: Despite system-wide 2-space indentation, respect existing 4-space indentation in Lua files
- **Error Handling**: Use descriptive assertion messages with `builtins.assert`
- **Comments**: Use comments to explain complex expressions, not obvious code
- **Git Practice**: Create focused commits with descriptive messages