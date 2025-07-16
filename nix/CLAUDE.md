# NixOS Dotfiles Guidelines

## Build/Test Commands
- `home-manager switch --flake .` - Apply Home Manager configuration
- `nix build .#homeConfigurations.spiros.activationPackage` - Build home-manager config
- `nix flake update` - Update flake dependencies
- `nixfmt flake.nix` - Format Nix files

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