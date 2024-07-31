
call plug#begin('~/.vim/plugged')

" Git plugin
Plug 'tpope/vim-fugitive'

" ayu theme
Plug 'ayu-theme/ayu-vim'

" CoC - Conquer of Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Use fzf fuzzy search instead of the one built into coc
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim' " needed for previews
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}

Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install && yarn prepack'}

" Add icons. Supported by coc-fzf-preview and some other plugins.
" Requires to use a font that supports icons, like nerd fonts.
Plug 'ryanoasis/vim-devicons'

" C++ semantic highlighting using lanaguage server protocol
Plug 'jackguo380/vim-lsp-cxx-highlight'

" clang format plugin
Plug 'rhysd/vim-clang-format'

" Fancy start page
Plug 'mhinz/vim-startify'

" Full path fuzzy file, buffer, mru, tag, ... finder for Vim
"Plug 'ctrlpvim/ctrlp.vim'

" Syntax highlighting and indentation support for many languages
Plug 'sheerun/vim-polyglot'

" quoting/parenthesizing made simple.
Plug 'tpope/vim-surround'

" Lines to indicate indentation level
Plug 'Yggdroot/indentLine'

" Elegant statusline
Plug 'liuchengxu/eleline.vim'

" Case keeping search and replace (and other things)
Plug 'tpope/vim-abolish'

" Tab utilities. Mainly tab renaming.
" Plug 'gcmt/taboo.vim'
Plug 'webdevel/tabulous'

" Lines to indicate indentation level
Plug 'Yggdroot/indentLine'

" Comment code shortcuts
" Plug 'scrooloose/nerdcommenter'
" Plug 'tpope/vim-commentary'
Plug 'tomtom/tcomment_vim'

" Auto change directory to project root
Plug 'airblade/vim-rooter'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Bookmarks
Plug 'MattesGroeger/vim-bookmarks'

" Elixir support
Plug 'elixir-editors/vim-elixir'

" Auto change directory to project root
Plug 'airblade/vim-rooter'

call plug#end()

" Map F2 to open NERDTree
"nmap <F2> :NERDTree<CR>

" Map F3 to open Gundo window
"nnoremap <F3> :GundoToggle<CR>

" Map F8 to toggle Tagbar
"nmap <F8> :TagbarToggle<CR>

" use gj and gk instead of j and k to handle long lines of text easier
nnoremap j gj
nnoremap k gk

" ctrl-backspace will delete to beginning of word in insert mode
inoremap <C-BS> <C-W>

" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
" Backspacing over a tab (4 spaces) backspaces 4 spaces
set softtabstop=4

if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

let s:fontType = 'Consolas NF'
let s:fontSize = 11
let &guifont = s:fontType . ":h" . s:fontSize

" Function to increase/decrease font size
function! AdjustFontSize(amount)
  let s:fontSize = s:fontSize+a:amount
  :execute "GuiFont!" . s:fontType . ':h' . string(s:fontSize)
endfunction

noremap <C-=> :call AdjustFontSize(1)<CR>
noremap <C--> :call AdjustFontSize(-1)<CR>

" Display line numbers
set number

" Show line numbers as relative to the current line
set relativenumber

" Needed for vim-devicons plugin
set encoding=UTF-8

" Highlight all search matches in file
set hlsearch

" Highlight the next search match as I type
set incsearch

" Allow backspace to delete across line breaks
set backspace=indent,eol,start

" Better way to move through windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove<cr>
" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/<cr>

" Mappings to cycle through tabs
nnoremap <C-n> gT
nnoremap <C-m> gt

" Mappings to move tabs with ALT
nnoremap <A-n> :tabmove -1<cr>
nnoremap <A-m> :tabmove +1<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>


" Add the dependecies folder to the path
let s:dependsdir = $HOME . '/vimfiles/depends'
if (has('win32') || has('win64')) && isdirectory(s:dependsdir)
    let $PATH .= ';' . s:dependsdir
endif

" Get correct comment highlighting in json files with comments.
autocmd FileType json syntax match Comment +\/\/.\+$+

" Remember tab names in session file
set sessionoptions+=tabpages,globals

" Restore folds with session files
set sessionoptions+=folds

" Map F5 to check if any buffers have changed on disk
nnoremap <F5> :<C-u>checktime<cr>

" Add a marker at column 100
set colorcolumn=100

" This snippet was taken from:
" https://www.reddit.com/r/neovim/comments/f0qx2y/automatically_reload_file_if_contents_changed/
 " trigger `autoread` when files changes on disk
set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" notification after file change
autocmd FileChangedShellPost *
\ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None


" ~~~~~~~~~~~~ Plugin setttings

" colorscheme settings
set termguicolors     " enable true colors support
let ayucolor="mirage" " for mirage version of theme
colorscheme ayu

" Startify to use devicons
function! StartifyEntryFormat()
   return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

" Always show status line (recommended in eleline readme)
set laststatus=2

" Enable ranibow parentheses
let g:rainbow_active=1

" vim-bookmarks config
highlight BookmarkSign ctermbg=NONE ctermfg=160
let g:bookmark_sign = '⚑'

" Rename tab shortcut
nnoremap <leader>tr :<C-u>call g:tabulous#renameTab()<cr>

" Start fzf in a popup window
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

" ~~ CoC settings
" TextEdit might fail if hidden is not set.
set hidden
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if has('patch8.1.1068')
  " Use `complete_info` if your (Neo)Vim version supports it.
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Add CocList sources that aren't supported by default
" add_list_source(name, description, command)
"call coc_fzf#common#add_list_source('fzf-grep', 'search using ripgrep', 'grep')

" Mappings using CoCList:
nnoremap <silent> <space>l  :<C-u>CocFzfList<CR>
" Resume latest coc list.
nnoremap <silent> <space>r  :<C-u>CocFzfListResume<CR>
" Show all files
nnoremap <silent> <space>f  :<C-u>CocFzfList files<cr>
nnoremap <C-p> :<C-u>CocList files<cr>
" Show most recently used files
nnoremap <silent> <space>m  :<C-u>CocFzfList mru<cr>

" Show all open buffers
nnoremap <silent> <space>b  :<C-u>CocFzfList fzf-buffers<cr>
" Grep from current working directory
nnoremap <silent> <space>g  :<C-u>CocFzfList grep<CR>
" Show all diagnostics.
nnoremap <silent> <space>d  :<C-u>CocFzfList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocFzfList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocFzfList -I symbols<cr>

" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>

call coc_fzf#common#add_list_source('fzf-buffers', 'display open buffers', 'Buffers')

"" grep word under cursor shortcut
command! -nargs=+ -complete=custom,s:GrepArgs Rg exe 'CocFzfList grep '.<q-args>
function! s:GrepArgs(...)
  let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
        \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
  return join(list, "\n")
endfunction
" Keymapping for grep word under cursor with interactive mode
nnoremap <silent> <space>wg :exe 'CocFzfList -I --input='.expand('<cword>').' grep'<CR>

"" grep for visual selection shortcut
vnoremap <space>vg :<C-u>call <SID>GrepFromSelected(visualmode())<CR>
nnoremap <space>vg :<C-u>set operatorfunc=<SID>GrepFromSelected<CR>g@
function! s:GrepFromSelected(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let word = substitute(@@, '\n$', '', 'g')
  let word = escape(word, '| ')
  let @@ = saved_unnamed_register
  execute 'CocFzfList grep '.word
endfunction


"" coc extensions
let g:coc_global_extensions = [
        \'coc-marketplace',
        \'coc-lists',
        \'coc-highlight',
        \'coc-explorer',
        \'coc-json',
        \'coc-eslint',
        \'coc-tsserver',
        \'coc-svelte',
        \'coc-json',
        \'coc-html',
        \'coc-css',
        \'coc-clangd',
        \'coc-git'
        \]

"" coc-explorer settings
nnoremap <leader>e :<C-u>CocCommand explorer<cr>

" ~~~~~~~~~~~ Startup commands
"
" Start in $HOME directory
cd $HOME

