# NixOS Dotfiles Guidelines

## Build/Test Commands
- `nixos-rebuild switch --flake .#<hostname>` - Apply full system configuration (includes home-manager)
- `home-manager switch --flake .#<hostname>` - Apply only Home Manager configuration independently
- `nix run github:nix-community/home-manager/release-24.11 -- switch --flake .#<hostname>` - Run home-manager without installing it
- `nix build .#homeConfigurations.<hostname>.activationPackage` - Build home-manager config
- `nix flake update` - Update flake dependencies
- `nixfmt flake.nix` - Format Nix files

Available hostnames: nixos, x1, t5600, t7910, msi_gs66, msi_ms16, vbox

## Dev Mode
- **Dev Mode**: Systems with `enableDevMode = true` (t5600, msi_ms16) create symlinks for Neovim configs
- **Benefits**: Edit Neovim Lua configs directly in `~/dotfiles/nix/home/nvim/lua/` for instant changes without rebuilds
- **Normal Mode**: Other systems copy configs to Nix store (immutable, requires rebuild for changes)

## Notes
- The `home-manager` CLI is installed system-wide, so you can use `home-manager switch --flake .#<hostname>` directly after a system rebuild

## OpenCode Agents

### Neovim Configuration Agent
**Location**: `.opencode/agent/neovim-config.md`
**Purpose**: Specialized agent for NixOS Neovim configuration management and plugin integration

**Usage**:
```bash
# Invoke the agent in opencode
@neovim-config help me add the telescope-file-browser plugin

# Or use directly in conversation
I need to configure the LSP for Rust development
```

**Capabilities**:
- Add new Neovim plugins with proper Nix packaging
- Configure existing plugins with Lua configuration files
- Set up LSP servers and completion systems
- Manage keybindings and resolve conflicts
- Handle dev mode vs normal mode differences
- Validate configurations and test builds

**Key Features**:
- Follows established repository patterns and conventions
- Handles both stable and unstable nixpkgs sources
- Manages plugin dependencies and load order
- Provides comprehensive testing and validation
- Supports rapid iteration in dev mode environments

### Agent Builder Agent
**Location**: `.opencode/agent/agent-builder.md`
**Purpose**: Specialized agent for creating comprehensive OpenCode agent instruction files using MCD methodology

**Usage**:
```bash
# Invoke the agent in opencode
@agent-builder create an agent for Docker container management

# Or use directly in conversation
I need an agent that can help with database migrations in this Rails project
```

**Capabilities**:
- Complete MCD methodology implementation with all 8 sections
- OpenCode-compatible YAML frontmatter and markdown structure
- Repository-aware pattern recognition and convention following
- Comprehensive workflow design with task breakdown and dependencies
- Detailed testing and validation strategies
- Operational procedures and maintenance guidelines

**Key Features**:
- Generates complete, actionable agents on first attempt
- Follows cognitive empathy principles for AI instruction
- Creates repository-specific patterns and examples
- Implements comprehensive quality assurance processes
- Provides detailed operational and maintenance procedures

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