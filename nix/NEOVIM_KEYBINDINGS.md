# Neovim Keybindings Reference

## Neo-tree File Explorer

Neo-tree is a modern file explorer for Neovim with enhanced features including git integration, buffer management, and multi-file operations.

### Main Toggle Commands

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Leader>e` | Toggle filesystem | Open/close Neo-tree filesystem view |
| `<Leader>bf` | Toggle buffers | Open/close Neo-tree buffer view |
| `<Leader>gs` | Toggle git status | Open/close Neo-tree git status view |
| `<Leader>gf` | Reveal current file | Show current file in Neo-tree |
| `<Leader>ff` | Follow current file | Follow current file in Neo-tree |

### Focus Commands

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Leader>tf` | Focus filesystem | Focus Neo-tree filesystem view |
| `<Leader>tb` | Focus buffers | Focus Neo-tree buffer view |
| `<Leader>tg` | Focus git status | Focus Neo-tree git status view |
| `<Leader>tr` | Reveal file | Reveal current file in Neo-tree |
| `<Leader>tc` | Close all | Close all Neo-tree windows |

### Navigation Within Neo-tree

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<CR>` | Open/Enter | Open file or enter directory |
| `<Tab>` | Toggle folder | Expand/collapse directory (primary) |
| `<Space>` | Toggle node | Expand/collapse directory (alternative) |
| `<2-LeftMouse>` | Open | Open file with double-click |
| `<BS>` | Navigate up | Go to parent directory |
| `.` | Set root | Set current directory as root |
| `P` | Toggle preview | Show/hide file preview |
| `l` | Focus preview | Focus the preview window |
| `q` | Close window | Close Neo-tree window |
| `<Esc>` | Cancel | Cancel current operation |

### File Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `a` | Add file/directory | Create new file or directory (prompts for type) |
| `A` | Add directory | Create new directory |
| `d` | Delete | Delete selected file/directory |
| `r` | Rename | Rename selected file/directory |
| `c` | Copy | Copy file/directory to another location |
| `m` | Move | Move file/directory to another location |
| `y` | Copy to clipboard | Copy file/directory to system clipboard |
| `x` | Cut to clipboard | Cut file/directory to system clipboard |
| `p` | Paste from clipboard | Paste from system clipboard |

### Path Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Y` | Copy full path | Copy full file path to clipboard |
| `gy` | Copy relative path | Copy relative file path to clipboard |
| `gY` | Copy filename | Copy just the filename to clipboard |

### Window Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `S` | Horizontal split | Open file in horizontal split |
| `s` | Vertical split | Open file in vertical split |
| `t` | New tab | Open file in new tab |
| `w` | Window picker | Open file using window picker |

### View and Display

| Keybinding | Action | Description |
|------------|--------|-------------|
| `H` | Toggle hidden | Show/hide hidden files |
| `R` | Refresh | Refresh the tree view |
| `i` | File details | Show detailed file information |
| `?` | Show help | Display help for current view |
| `<` | Previous source | Switch to previous source (filesystem/buffers/git) |
| `>` | Next source | Switch to next source |

### Tree Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `C` | Close node | Close/collapse current node |
| `z` | Close all nodes | Collapse all expanded nodes |
| `Z` | Expand all nodes | Expand all nodes in current directory |

### Search and Filter

| Keybinding | Action | Description |
|------------|--------|-------------|
| `/` | Fuzzy finder | Search files in current directory |
| `D` | Directory finder | Search directories |
| `#` | Fuzzy sorter | Sort files with fuzzy matching |
| `f` | Filter on submit | Apply filter to current view |
| `<C-x>` | Clear filter | Clear current filter |

### Sorting Options

All sorting commands are prefixed with `o`:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `o` | Show sort menu | Display sorting options |
| `oc` | Sort by created | Sort by creation date |
| `od` | Sort by diagnostics | Sort by diagnostic status |
| `og` | Sort by git status | Sort by git status |
| `om` | Sort by modified | Sort by modification date |
| `on` | Sort by name | Sort alphabetically by name |
| `os` | Sort by size | Sort by file size |
| `ot` | Sort by type | Sort by file type |

### Git Operations (Git Status View)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `A` | Git add all | Stage all changes |
| `ga` | Git add file | Stage selected file |
| `gu` | Git unstage file | Unstage selected file |
| `gr` | Git revert file | Revert changes in selected file |
| `gc` | Git commit | Commit staged changes |
| `gp` | Git push | Push commits to remote |
| `gg` | Git commit and push | Commit and push in one action |
| `[g` | Previous git change | Navigate to previous git modified file |
| `]g` | Next git change | Navigate to next git modified file |

### Buffer Operations (Buffer View)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `bd` | Buffer delete | Delete/close selected buffer |

### Git Status Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `[c` | Previous change | Go to previous git change |
| `]c` | Next change | Go to next git change |

## Git Status Symbols

Neo-tree displays git status using these symbols:

| Symbol | Status | Description |
|--------|--------|-------------|
| `✚` | Added | New file added to git |
| `` | Modified | File has been modified |
| `✖` | Deleted | File has been deleted |
| `󰁕` | Renamed | File has been renamed |
| `` | Untracked | File not tracked by git |
| `` | Ignored | File ignored by git |
| `󰄱` | Unstaged | File has unstaged changes |
| `` | Staged | File has staged changes |
| `` | Conflict | File has merge conflicts |

## Usage Tips

### Quick Workflow Examples

1. **Basic file navigation:**
   - `<Leader>e` - Open Neo-tree
   - Navigate with arrow keys or `hjkl`
   - `<CR>` to open files
   - `<BS>` to go up directories

2. **File management:**
   - `a` to create new files/directories
   - `r` to rename
   - `d` to delete
   - `c` to copy, `m` to move

3. **Git workflow:**
   - `<Leader>gs` - Open git status view
   - `ga` to stage files
   - `gc` to commit
   - `gp` to push

4. **Buffer management:**
   - `<Leader>bf` - Open buffer view
   - Navigate and `bd` to close buffers

5. **Search and organize:**
   - `/` to search within current directory
   - `H` to toggle hidden files
   - `o` + sort key to organize files

### Advanced Features

- **Auto-close**: Neo-tree automatically closes when opening a file
- **Preview**: Use `P` to preview files without opening them
- **Multi-view**: Switch between filesystem, buffers, and git status
- **Path operations**: Copy paths in various formats with `Y`, `gy`, `gY`
- **Window integration**: Open files in splits, tabs, or specific windows

### Migration from nvim-tree

If you're coming from nvim-tree, the main differences are:

- **Enhanced git integration**: Better git status display and operations
- **Multiple views**: Filesystem, buffers, and git status in one plugin
- **Better performance**: More efficient tree rendering
- **Modern UI**: Improved icons and visual indicators
- **Advanced operations**: More file management capabilities

The core navigation (`<Leader>e` to toggle) remains the same for a smooth transition.