
# Neovim Configuration Cleanup and Restructure

## Background

### The Problem
Our Neovim configuration is currently broken due to a failed migration attempt that created conflicts between different configuration management approaches. The system exhibits several critical issues:

1. **Build Failures**: Home Manager fails to deploy with "Read-only file system" errors
2. **Invalid Plugin Specs**: Lazy.nvim receives module objects instead of plugin specifications
3. **Configuration Conflicts**: Multiple systems trying to manage the same files
4. **Persistent State Issues**: Old keybindings remain active despite configuration changes
5. **Stack Overflows**: Circular dependencies in plugin loading

### Root Cause Analysis
The fundamental issue stems from mixing incompatible configuration patterns:

- **Conflicting File Management**: Both `programs.neovim` and `xdg.configFile` trying to manage the same directories
- **Wrong Plugin Loading**: Using `require()` calls that return module objects instead of lazy.nvim plugin specifications
- **Path Mismatches**: Lazy.nvim looking for plugins in `lua/plugins/` but files located in `lua/`
- **Improper Lazy Integration**: Attempting to load plugin configurations outside of lazy.nvim's spec system

### Current Architecture Problems
```
❌ BROKEN: Current State
├── home.nix (conflicting xdg.configFile entries)
├── programs.neovim (massive extraLuaConfig with require() calls)
└── lua/ (plugin files returning lazy specs but loaded incorrectly)
```

### Why This Matters
- **NixOS Philosophy**: The entire point of NixOS is reproducible, declarative configurations
- **Development Productivity**: Broken configs block all Neovim-based development work
- **System Reliability**: Configuration drift undermines the benefits of using Nix
- **Maintenance Burden**: Complex, broken configs are impossible to maintain or debug

## Proposed Solution: Hybrid Nix + Lazy.nvim + Dev Mode

### Core Philosophy
We want to leverage the strengths of each tool:

- **Nix**: Package management, plugin installation, system integration, reproducibility
- **Lazy.nvim**: Plugin configuration, lazy loading, advanced features, keymaps
- **Dev Mode**: Live configuration editing for rapid development iteration

### Target Architecture
```
✅ CLEAN: Target State
├── home.nix (plugin installation only)
├── nvim/init.lua (minimal bootstrap)
├── nvim/lua/config/ (core Neovim settings)
└── nvim/lua/plugins/ (lazy.nvim specifications)
```

### Key Principles

#### 1. Separation of Concerns
- **Plugin Installation**: Nix handles ALL plugin installation via `programs.neovim.plugins`
- **Plugin Configuration**: Lazy.nvim handles configuration, loading, and features
- **Core Settings**: Separate files for options, keymaps, and autocommands

#### 2. Single Source of Truth
- **Plugins**: Installed only through Nix, never through lazy.nvim
- **Versions**: Locked by Nix flake.lock, no version conflicts
- **Configuration**: Each plugin configured in exactly one place

#### 3. Development Ergonomics
- **Dev Mode**: Symlinked configs for live editing (no rebuilds needed)
- **Production Mode**: Immutable configs copied to Nix store
- **Per-System**: Different systems can use different modes

### Benefits of This Approach

#### Reliability Benefits
- ✅ **Reproducible**: Identical configs across all systems
- ✅ **Offline**: No network dependencies during Neovim startup
- ✅ **Atomic**: Changes either fully apply or fully fail
- ✅ **Rollback**: Can revert to any previous generation

#### Development Benefits
- ✅ **Live Editing**: Config changes apply immediately in dev mode
- ✅ **Lazy Loading**: Get performance benefits of lazy.nvim
- ✅ **Advanced Features**: Conditional loading, dependencies, etc.
- ✅ **Clean Structure**: Organized, maintainable configuration

#### Operational Benefits
- ✅ **No Conflicts**: Clear boundaries between tools
- ✅ **Easy Debugging**: Predictable loading order and structure
- ✅ **Maintainable**: Simple, understandable architecture
- ✅ **Scalable**: Easy to add/remove plugins and features

## Detailed Implementation Plan

### Phase 1: Analysis and Preparation (30 minutes)

#### 1.1 Current State Assessment
**Objective**: Understand exactly what we have and what needs to change

**Tasks**:
- **Plugin Inventory**: List all plugins currently in `programs.neovim.plugins`
- **Configuration Audit**: Document all settings in current `extraLuaConfig`
- **File Mapping**: Catalog all files in `home/nvim/lua/` and their purposes
- **Dependency Analysis**: Map plugin dependencies and loading requirements
- **Keymap Documentation**: Extract all custom keybindings for preservation

**Deliverables**:
- Complete plugin list with versions
- Current configuration breakdown
- File-by-file migration plan
- Dependency graph

#### 1.2 Architecture Planning
**Objective**: Design the new structure before implementing

**Tasks**:
- **Directory Design**: Plan the new `lua/config/` and `lua/plugins/` structure
- **Migration Strategy**: Determine order of operations for safe migration
- **Dev Mode Integration**: Plan how `enableDevMode` flag will work
- **Rollback Planning**: Ensure we can revert if things go wrong

**Deliverables**:
- New directory structure diagram
- Step-by-step migration plan
- Rollback procedures documented

### Phase 2: Core Infrastructure Changes (45 minutes)

#### 2.1 Home Manager Configuration Cleanup
**File**: `home/home.nix`

**Objective**: Remove all conflicting configuration and establish clean foundation

**Specific Changes**:
```nix
# REMOVE: All broken require() calls (lines ~317-350)
# REMOVE: Conflicting xdg.configFile entries
# REMOVE: Massive extraLuaConfig section

# KEEP: Plugin installation in programs.neovim.plugins
# ADD: Clean dev mode conditional for xdg.configFile
```

**New Structure**:
```nix
programs.neovim = {
  enable = true;
  vimAlias = true;
  vimdiffAlias = true;
  withNodeJs = true;
  plugins = with pkgs.vimPlugins; [
    lazy-nvim
    telescope-nvim
    nvim-lspconfig
    # ... ALL plugins listed here ONLY
  ];
  # NO extraLuaConfig - handled by separate files
};

xdg.configFile = if flags.enableDevMode then {
  # Dev mode: symlink for live editing
  "nvim".source = config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/dotfiles/nix/home/nvim";
} else {
  # Production mode: copy to nix store
  "nvim" = {
    source = ./nvim;
    recursive = true;
  };
};
```

#### 2.2 New Directory Structure Creation
**Objective**: Create clean, organized file structure

**New Files to Create**:
```
home/nvim/
├── init.lua                    # Main entry point
├── lua/
│   ├── config/
│   │   ├── options.lua         # Vim options (tabstop, number, etc.)
│   │   ├── keymaps.lua         # Core keymaps (leader, basic navigation)
│   │   ├── autocmds.lua        # Autocommands (markdown, autoread)
│   │   └── lazy.lua            # Lazy.nvim setup and configuration
│   └── plugins/
│       ├── telescope.lua       # File finding and search
│       ├── lsp.lua            # Language server configuration
│       ├── completion.lua      # Blink-cmp setup
│       ├── treesitter.lua     # Syntax highlighting
│       ├── git.lua            # Neogit and git integration
│       ├── ui.lua             # Neo-tree, which-key, etc.
│       ├── ai.lua             # Avante and AI tools
│       └── ...                # Other plugin categories
```

#### 2.3 Content Migration Strategy
**Objective**: Move existing configuration to appropriate new locations

**From Current `extraLuaConfig` Extract**:
- **Leader Keys**: `vim.g.mapleader = ";"` → `init.lua`
- **Vim Options**: `vim.opt.tabstop`, `vim.wo.number` → `config/options.lua`
- **Core Keymaps**: Non-plugin specific bindings → `config/keymaps.lua`
- **Autocommands**: File type settings, autoread → `config/autocmds.lua`
- **Plugin Setup**: Individual plugin configs → `plugins/*.lua`

**From Current `lua/` Files**:
- Transform from current format to proper lazy.nvim specifications
- Preserve all configuration logic and keymaps
- Remove any installation-related fields

### Phase 3: Plugin Configuration Transformation (60 minutes)

#### 3.1 Lazy Specification Conversion Pattern
**Objective**: Convert existing plugin files to proper lazy.nvim specs

**Current Format** (BROKEN):
```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({ ... })
    end,
  }
}
```

**New Format** (CORRECT):
```lua
return {
  "nvim-telescope/telescope.nvim",
  -- NO installation fields - Nix handles installation
  dependencies = { "nvim-lua/plenary.nvim" }, -- Must also be in Nix
  lazy = true,
  cmd = { "Telescope" },
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<C-g>", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
  },
  config = function()
    require("telescope").setup({
      -- Configuration preserved exactly
    })
  end,
}
```

#### 3.2 Plugin Priority and Conversion Order
**High Priority** (Core Functionality):
1. **telescope.lua** - File finding, essential for development workflow
2. **lsp.lua** - Language servers, critical for coding
3. **completion.lua** - Blink-cmp, essential for productivity
4. **treesitter.lua** - Syntax highlighting, fundamental feature
5. **ui.lua** - Neo-tree, which-key, basic UI components

**Medium Priority** (Development Tools):
6. **git.lua** - Neogit, version control integration
7. **debug.lua** - DAP debugging tools
8. **ai.lua** - Avante and AI assistance (handle carefully due to previous issues)
9. **editing.lua** - Text manipulation plugins (surround, etc.)

**Low Priority** (Nice-to-Have):
10. **themes.lua** - Color schemes and appearance
11. **misc.lua** - Utility plugins and experimental features

#### 3.3 Dependency Resolution Strategy
**Objective**: Ensure all plugin dependencies are properly managed

**For Each Plugin**:
- **Nix Dependencies**: Verify all `dependencies` in lazy spec are installed via Nix
- **Loading Order**: Ensure plugins load in correct sequence
- **Optional Dependencies**: Handle plugins that enhance others when present
- **Circular Dependencies**: Identify and resolve any circular references

**Common Dependency Patterns**:
```lua
-- Example: Telescope with extensions
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",           -- Core dependency
    "nvim-tree/nvim-web-devicons",     -- Icons
    "nvim-telescope/telescope-fzf-native.nvim", -- Performance
  },
  -- All dependencies must be in Nix plugins list
}
```

### Phase 4: Core Configuration Files (30 minutes)

#### 4.1 init.lua Structure
**Objective**: Create clean, minimal entry point

```lua
-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Load core Neovim configuration
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings
require("config.autocmds")   -- Autocommands

-- Initialize plugin system
require("config.lazy")       -- Lazy.nvim setup
```

#### 4.2 config/lazy.lua Setup
**Objective**: Configure lazy.nvim for Nix integration

```lua
-- config/lazy.lua
local lazy = require("lazy")

lazy.setup({
  spec = { import = "plugins" },
  
  -- Nix integration settings
  performance = {
    reset_packpath = false,  -- Don't interfere with Nix paths
    rtp = { reset = false }, -- Preserve runtime path
  },
  
  -- Disable installation features
  install = { missing = false },    -- Never install plugins
  checker = { enabled = false },    -- No update checking
  change_detection = { enabled = false }, -- No file watching
  
  -- UI settings
  ui = {
    border = "rounded",
    title = "Plugin Manager",
  },
})
```

#### 4.3 Configuration File Content
**config/options.lua**:
```lua
-- Core Vim options extracted from current config
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoread = true
vim.opt.showmode = false
-- ... all other vim.opt settings
```

**config/keymaps.lua**:
```lua
-- Core keymaps (non-plugin specific)
vim.keymap.set('n', '<C-m>', ':tabnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-n>', ':tabprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'Y', 'yy', { noremap = true, silent = true })
-- ... all core keymaps
```

**config/autocmds.lua**:
```lua
-- Autocommands for file types and behaviors
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  command = "checktime"
})

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- All markdown configuration
  end,
})
```

### Phase 5: Dev Mode Implementation (20 minutes)

#### 5.1 Flag-Based Configuration
**Objective**: Enable different behavior for development vs production

**System Configuration**:
```nix
# In flake.nix systemDefs
t5600 = {
  flags = flags // {
    enableDevMode = true;  # Gaming/dev system
  };
};

msi_ms16 = {
  flags = flags // {
    enableDevMode = true;  # Development system
  };
};

x1 = {
  flags = flags // {
    enableDevMode = false; # Production laptop
  };
};
```

#### 5.2 Dev Mode Benefits
**Development Workflow**:
1. Edit files in `/home/spiros/dotfiles/nix/home/nvim/`
2. Changes apply immediately (no rebuild needed)
3. Can experiment rapidly with configurations
4. Still get all lazy.nvim features

**Production Workflow**:
1. Edit files in repository
2. Run `home-manager switch --flake .#hostname`
3. Changes applied immutably
4. Guaranteed reproducible across systems

### Phase 6: Testing and Validation (45 minutes)

#### 6.1 Build Validation Process
**Objective**: Ensure configurations build before deployment

**Test Sequence**:
```bash
# 1. Validate flake syntax
nix flake check

# 2. Build home manager config
nix build .#homeConfigurations.x1.activationPackage

# 3. Build system config
nix build .#nixosConfigurations.x1.config.system.build.toplevel

# 4. Test other systems
for system in t5600 t7910 msi_gs66 msi_ms16 vbox; do
  nix build .#homeConfigurations.$system.activationPackage
done
```

#### 6.2 Deployment Testing Strategy
**Staged Rollout**:
1. **Test System**: Deploy to x1 first (current development system)
2. **Basic Validation**: Verify Neovim starts without errors
3. **Core Features**: Test file editing, basic navigation
4. **Plugin Features**: Test telescope, LSP, completion incrementally
5. **Full Workflow**: Test complete development workflow
6. **Other Systems**: Deploy to remaining systems once stable

#### 6.3 Functionality Validation Checklist
**Critical Features**:
- [ ] Neovim starts without errors or warnings
- [ ] Leader keys work correctly (`;` and `,`)
- [ ] File finding with telescope (`<C-p>`, `<C-g>`)
- [ ] LSP functionality (hover, go-to-definition, diagnostics)
- [ ] Completion system works
- [ ] Syntax highlighting active
- [ ] Git integration functional
- [ ] All custom keymaps work
- [ ] Markdown-specific features work
- [ ] Tab navigation and management

**Performance Validation**:
- [ ] Startup time reasonable (< 100ms)
- [ ] Lazy loading working (plugins load on demand)
- [ ] No memory leaks or excessive resource usage
- [ ] File operations responsive

### Phase 7: Cleanup and Documentation (15 minutes)

#### 7.1 Repository Cleanup
**Files to Remove**:
- `home/home.nix.backup` (after confirming new config works)
- Any temporary or test files created during migration
- Old configuration approaches that are no longer used

**Files to Update**:
- Update README.md with new architecture explanation
- Document dev mode vs production mode differences
- Update any setup or installation instructions

#### 7.2 Documentation Requirements
**Architecture Documentation**:
- Explain the hybrid Nix + lazy.nvim approach
- Document the separation of concerns
- Explain dev mode vs production mode

**Usage Documentation**:
- How to add new plugins
- How to modify configurations
- How to troubleshoot issues
- How to switch between dev and production modes

## Risk Assessment and Mitigation

### High-Risk Areas

#### 1. Plugin Compatibility Issues
**Risk**: Some plugins may not work correctly with Nix-managed installation
**Mitigation**: 
- Test each plugin individually during conversion
- Have fallback configurations for problematic plugins
- Document any plugins that require special handling

#### 2. Dependency Resolution Problems
**Risk**: Missing or incorrect plugin dependencies
**Mitigation**:
- Carefully audit all plugin dependencies
- Test dependency chains thoroughly
- Maintain comprehensive dependency documentation

#### 3. Dev Mode Symlink Issues
**Risk**: Symlinks may not work correctly or cause permission problems
**Mitigation**:
- Test dev mode on multiple systems
- Have production mode as fallback
- Document symlink troubleshooting procedures

### Medium-Risk Areas

#### 4. Configuration Migration Errors
**Risk**: Settings or keymaps lost during migration
**Mitigation**:
- Comprehensive documentation of current configuration
- Incremental migration with testing at each step
- Maintain backup of working configuration

#### 5. Lazy.nvim Integration Issues
**Risk**: Lazy.nvim may not work correctly with Nix-installed plugins
**Mitigation**:
- Follow established patterns from community
- Test lazy loading functionality thoroughly
- Have fallback to direct loading if needed

### Low-Risk Areas

#### 6. Build System Changes
**Risk**: Home Manager or Nix build issues
**Mitigation**:
- Test builds before deployment
- Use incremental changes
- Maintain rollback capability

## Success Criteria

### Functional Requirements
- [ ] **No Errors**: Neovim starts without any error messages
- [ ] **All Features Work**: Every current feature continues to function
- [ ] **Performance**: Startup time and responsiveness maintained or improved
- [ ] **Reproducibility**: Identical behavior across all systems
- [ ] **Dev Mode**: Live editing works correctly on dev systems
- [ ] **Production Mode**: Immutable configs work on production systems

### Technical Requirements
- [ ] **Clean Architecture**: Clear separation between Nix and lazy.nvim responsibilities
- [ ] **Maintainable Code**: Well-organized, documented configuration
- [ ] **No Conflicts**: No competing systems managing the same resources
- [ ] **Proper Dependencies**: All plugin dependencies correctly managed
- [ ] **Build Success**: All systems build and deploy successfully

### Operational Requirements
- [ ] **Easy Plugin Addition**: Simple process to add new plugins
- [ ] **Easy Configuration Changes**: Straightforward to modify settings
- [ ] **Good Documentation**: Clear instructions for maintenance and troubleshooting
- [ ] **Rollback Capability**: Can revert to previous working state if needed

## Implementation Timeline

**Total Estimated Time**: 4-5 hours

- **Phase 1** (Analysis): 30 minutes
- **Phase 2** (Infrastructure): 45 minutes  
- **Phase 3** (Plugin Conversion): 60 minutes
- **Phase 4** (Core Config): 30 minutes
- **Phase 5** (Dev Mode): 20 minutes
- **Phase 6** (Testing): 45 minutes
- **Phase 7** (Cleanup): 15 minutes
- **Buffer Time**: 30 minutes for unexpected issues

This plan provides a systematic approach to migrate from the current broken state to a clean, maintainable, and feature-rich Neovim configuration that leverages the best aspects of both Nix and lazy.nvim while providing excellent development ergonomics.
