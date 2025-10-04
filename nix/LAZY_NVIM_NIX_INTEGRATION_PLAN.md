# Lazy.nvim + Nix Integration Fix Plan

## Executive Summary

This document outlines a comprehensive plan to fix the current Neovim configuration issue where lazy.nvim cannot find Nix-installed plugins. The solution involves implementing the nixCats lazy.nvim wrapper, which provides a proven bridge between Nix package management and lazy.nvim's plugin loading system.

## Background & Problem Analysis

### Current State
- ✅ **Basic configuration working**: Leader keys, tab settings, and lazy.nvim initialization
- ✅ **Lazy.nvim command available**: `:Lazy` command is functional
- ❌ **Plugin discovery failing**: Lazy.nvim cannot find Nix-installed plugins
- ❌ **Plugin configurations not loading**: All plugin specs fail with "Plugin X is not installed"

### Root Cause
The fundamental issue is an **architectural mismatch** between lazy.nvim's expectations and Nix's plugin management:

1. **Lazy.nvim expects self-management**: Looks for plugins in `~/.local/share/nvim/lazy/`
2. **Nix installs in store**: Plugins available at `/nix/store/.../pack/myNeovimPackages/start/`
3. **Plugin specs fail**: Lazy.nvim can't find plugins to load their configurations
4. **Runtime path works**: Plugins are available to Neovim but not to lazy.nvim's management system

### Error Manifestation
```
Error detected while processing /home/spiros/.config/nvim/init.lua:
Plugin snacks.nvim is not installed
Plugin nvim-treesitter is not installed
Plugin nvim-lspconfig is not installed
[... all plugins fail ...]
```

## Research Findings

### Available Solutions

#### 1. NixCats Approach ⭐ (Recommended)
- **Mature solution**: Specifically designed for this exact problem
- **Lazy.nvim wrapper**: `require('nixCatsUtils.lazyCat').setup()`
- **Proven templates**: kickstart-nvim and LazyVim examples available
- **Active maintenance**: Well-documented with comprehensive examples
- **Minimal migration**: Can reuse existing plugin configurations

#### 2. Manual Integration
- **Complex setup**: Requires deep understanding of both systems
- **Fragile**: Prone to breaking with updates
- **Limited documentation**: Few working examples available
- **High maintenance**: Requires ongoing adjustments

#### 3. Alternative Package Managers
- **lze/lz.n**: Designed for external package managers
- **Complete rewrite**: Would require converting all plugin configurations
- **Less ecosystem support**: Smaller community and fewer examples

### NixCats Architecture

NixCats provides a **dual-mode system**:
- **Nix mode**: When loaded via Nix, uses Nix-managed plugins
- **Fallback mode**: When loaded normally, falls back to lazy.nvim's standard behavior
- **Transparent integration**: Existing lazy.nvim specs work with minimal changes

## Implementation Plan: NixCats Integration

### Phase 1: Setup and Preparation

#### 1.1 Install NixCats Utilities
**Objective**: Add nixCats utilities to our configuration
**Actions**:
- Add nixCats flake input to `flake.nix`
- Import nixCats utilities into our Neovim configuration
- Set up the basic nixCats infrastructure

**Files Modified**:
- `flake.nix` - Add nixCats input
- `home/nvim/lua/nixCatsUtils/` - New directory with utilities

#### 1.2 Backup Current Configuration
**Objective**: Preserve working state for rollback
**Actions**:
- Create git commit with current working state
- Document current plugin list and configurations
- Test current basic functionality (leader keys, options)

### Phase 2: NixCats Integration

#### 2.1 Replace Lazy.nvim Setup
**Objective**: Replace direct lazy.nvim setup with nixCats wrapper
**Current Code**:
```lua
require("lazy").setup({
  spec = { { import = "plugins" } },
  performance = { reset_packpath = false, rtp = { reset = false } },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
})
```

**New Code**:
```lua
-- nixCats setup
require('nixCatsUtils').setup {
  non_nix_value = true,
}

-- Lazy wrapper setup
require('nixCatsUtils.lazyCat').setup(
  nixCats.pawsible({"allPlugins", "start", "lazy.nvim"}),
  { { import = "plugins" } },
  {
    performance = { reset_packpath = false, rtp = { reset = false } },
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
  }
)
```

#### 2.2 Update Plugin Specifications
**Objective**: Ensure plugin specs work with nixCats wrapper
**Required Changes**:
- Add conditional loading based on nixCats detection
- Use `nixCats.pawsible()` for plugin availability checks
- Maintain compatibility with both Nix and non-Nix environments

**Example Plugin Spec Update**:
```lua
-- Before
return {
  {
    "folke/snacks.nvim",
    config = function()
      require("snacks").setup({})
    end,
  },
}

-- After
return {
  {
    "folke/snacks.nvim",
    enabled = nixCats.pawsible({"plugins", "snacks"}),
    config = function()
      require("snacks").setup({})
    end,
  },
}
```

#### 2.3 Update Nix Configuration
**Objective**: Ensure Nix provides plugins in expected format
**Actions**:
- Verify all plugins are in `programs.neovim.plugins`
- Ensure lazy.nvim itself is included in Nix plugins
- Add any missing dependencies

### Phase 3: Plugin Configuration Migration

#### 3.1 Core Plugins Migration
**Priority Order**:
1. **Essential plugins**: lazy.nvim, plenary.nvim
2. **UI plugins**: snacks.nvim, which-key.nvim
3. **LSP plugins**: nvim-lspconfig, blink.cmp
4. **Utility plugins**: telescope, neo-tree
5. **Specialized plugins**: avante.nvim, obsidian.nvim

#### 3.2 Plugin-by-Plugin Updates
**For each plugin**:
1. Add `enabled = nixCats.pawsible()` check
2. Test plugin loading and functionality
3. Verify keybindings work correctly
4. Check for any nixCats-specific adjustments needed

#### 3.3 Dependency Management
**Objective**: Ensure proper plugin dependency handling
**Actions**:
- Map Nix plugin dependencies to lazy.nvim dependencies
- Verify load order is maintained
- Test plugin interdependencies

### Phase 4: Testing and Validation

#### 4.1 Functionality Testing
**Test Matrix**:
- ✅ Basic configuration (leader keys, options)
- ✅ Lazy.nvim command availability
- ✅ Plugin loading and initialization
- ✅ Plugin configurations and keybindings
- ✅ LSP functionality
- ✅ Completion system
- ✅ File navigation and search

#### 4.2 Environment Testing
**Test Scenarios**:
- **Nix environment**: Full functionality with Nix-managed plugins
- **Non-Nix environment**: Fallback to standard lazy.nvim behavior
- **Dev mode**: Symlinked configurations work correctly
- **Normal mode**: Immutable Nix store configurations

#### 4.3 Performance Validation
**Metrics**:
- Startup time comparison
- Plugin loading performance
- Memory usage
- Responsiveness during normal use

### Phase 5: Documentation and Cleanup

#### 5.1 Update Documentation
**Actions**:
- Update README with nixCats integration notes
- Document new plugin addition process
- Create troubleshooting guide
- Update keybinding documentation

#### 5.2 Configuration Cleanup
**Actions**:
- Remove obsolete configuration files
- Clean up unused Nix packages
- Optimize plugin loading order
- Remove debugging code

## Implementation Details

### NixCats Flake Integration

#### Flake Input Addition
```nix
# In flake.nix inputs section
nixCats = {
  url = "github:BirdeeHub/nixCats-nvim";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

#### Home Manager Integration
```nix
# In home.nix
programs.neovim = {
  enable = true;
  plugins = [
    # Include nixCats utilities
    inputs.nixCats.packages.${pkgs.system}.nixCats
    # ... existing plugins
  ];
};
```

### Plugin Configuration Pattern

#### Standard Plugin Spec
```lua
return {
  {
    "plugin-author/plugin-name",
    enabled = nixCats.pawsible({"plugins", "plugin-category"}),
    dependencies = {
      -- Dependencies handled by Nix when available
    },
    config = function()
      require("plugin-name").setup({
        -- Plugin configuration
      })
    end,
    keys = {
      -- Keybindings
    },
  },
}
```

#### Conditional Loading
```lua
-- For plugins that need different behavior on/off Nix
return {
  {
    "plugin-name",
    enabled = nixCats.pawsible({"plugins", "category"}),
    build = require('nixCatsUtils').lazyAdd(nil, ":SomeCommand"),
    config = function()
      if require('nixCatsUtils').isNixCats then
        -- Nix-specific configuration
      else
        -- Standard configuration
      end
    end,
  },
}
```

### Migration Checklist

#### Pre-Migration
- [ ] Create git commit with current state
- [ ] Document current plugin list
- [ ] Test basic functionality
- [ ] Backup configuration files

#### NixCats Setup
- [ ] Add nixCats flake input
- [ ] Install nixCats utilities
- [ ] Update init.lua with nixCats setup
- [ ] Replace lazy.nvim setup with wrapper

#### Plugin Migration
- [ ] Update core plugins (lazy.nvim, plenary)
- [ ] Migrate UI plugins (snacks, which-key)
- [ ] Update LSP plugins (lspconfig, completion)
- [ ] Migrate utility plugins (telescope, neo-tree)
- [ ] Update specialized plugins (avante, obsidian)

#### Testing
- [ ] Test basic configuration
- [ ] Verify plugin loading
- [ ] Check keybindings
- [ ] Test LSP functionality
- [ ] Validate completion system
- [ ] Test file operations

#### Cleanup
- [ ] Remove obsolete files
- [ ] Update documentation
- [ ] Optimize configuration
- [ ] Create final commit

## Risk Assessment

### Low Risk
- **Basic functionality**: Leader keys and options will continue working
- **Rollback capability**: Git history provides easy rollback
- **Incremental approach**: Can migrate plugins one by one

### Medium Risk
- **Plugin compatibility**: Some plugins may need adjustment
- **Keybinding conflicts**: May need to resolve binding issues
- **Performance impact**: Slight overhead from nixCats wrapper

### High Risk
- **Complex plugins**: Specialized plugins (avante.nvim) may need significant changes
- **LSP integration**: Language server setup may require updates
- **Custom configurations**: Heavily customized plugins may break

### Mitigation Strategies
1. **Incremental migration**: Migrate plugins in small batches
2. **Thorough testing**: Test each plugin after migration
3. **Backup strategy**: Maintain working configuration in git
4. **Documentation**: Keep detailed notes of changes made

## Success Criteria

### Primary Goals
- ✅ All plugins load without "not installed" errors
- ✅ Plugin configurations work correctly
- ✅ Keybindings function as expected
- ✅ LSP and completion systems operational
- ✅ No regression in basic functionality

### Secondary Goals
- ✅ Startup time maintained or improved
- ✅ Configuration remains maintainable
- ✅ Easy to add new plugins
- ✅ Works in both dev and normal modes
- ✅ Documentation is comprehensive

### Quality Metrics
- **Error-free startup**: No plugin loading errors
- **Feature parity**: All current features work
- **Performance**: Startup time < 500ms
- **Maintainability**: Clear plugin addition process

## Timeline

### Phase 1: Setup (Day 1)
- Morning: Add nixCats flake input and utilities
- Afternoon: Update init.lua with basic nixCats setup

### Phase 2: Core Migration (Day 1-2)
- Day 1 Evening: Replace lazy.nvim setup with wrapper
- Day 2 Morning: Migrate essential plugins (lazy, plenary, snacks)

### Phase 3: Plugin Migration (Day 2-3)
- Day 2 Afternoon: Migrate UI and utility plugins
- Day 3 Morning: Migrate LSP and completion plugins
- Day 3 Afternoon: Migrate specialized plugins

### Phase 4: Testing (Day 3-4)
- Day 3 Evening: Comprehensive functionality testing
- Day 4 Morning: Performance and edge case testing

### Phase 5: Cleanup (Day 4)
- Day 4 Afternoon: Documentation and final cleanup

## Conclusion

The nixCats approach provides a robust, well-tested solution to the lazy.nvim + Nix integration challenge. By following this comprehensive plan, we can resolve the current plugin loading issues while maintaining all existing functionality and improving the overall maintainability of the configuration.

The key advantages of this approach:
- **Proven solution** with active community support
- **Minimal disruption** to existing plugin configurations
- **Future-proof** design that handles updates gracefully
- **Dual-mode operation** supporting both Nix and non-Nix environments

This plan provides a clear path forward with manageable risk and high probability of success.