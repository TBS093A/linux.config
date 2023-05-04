" nvim plugins

  " vim-workspace script
    if empty(glob('~/.vim/autoload/plug.vim'))
      silent execute "!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      autocmd VimEnter * PlugInstall | source $MYVIMRC
    endif

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

  " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
    Plug 'junegunn/vim-easy-align'

  " Any valid git URL is allowed
    Plug 'https://github.com/junegunn/vim-github-dashboard.git'

  " Multiple Plug commands can be written in a single line using | separators
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

  " On-demand loading
    Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

  " Using a non-default branch
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

  " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
    Plug 'fatih/vim-go', { 'tag': '*' }

  " Provides an easy way to browse the tags of the current file and get an overview of its structure
  " It does this by creating a sidebar that displays the ctags-generated tags of the current file, ordered by their scope
  " This means that for example methods in C++ are displayed under the class they are defined in
  " https://vimawesome.com/plugin/tagbar
    Plug 'majutsushi/tagbar'

  " Add some css colors
  " https://vimawesome.com/plugin/vim-css-color-the-story-of-us
    Plug 'ap/vim-css-color'

  " Format code with one button press (or automatically on save).
  " https://vimawesome.com/plugin/vim-autoformat
    Plug 'chiel92/vim-autoformat'

  " Plugin options
    Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

  " Plugin outside ~/.vim/plugged with post-update hook
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

  " Unmanaged plugin (manually installed and updated)
    Plug '~/my-prototype-plugin'

  " vim-workspace for create sessions
  " https://vimawesome.com/plugin/vim-workspace
    Plug 'thaerkh/vim-workspace'

" Visual Studio Code plugins

  " coloured icons & explorer
  " https://github.com/nvim-tree/nvim-tree.lua
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'nvim-tree/nvim-web-devicons'

    " you need nerd fonts with special characters, on void you can do something like that:
    " ls -la /usr/share/fontconfig/conf.avail
    " sudo xbps-reconfigure -f fontconfig
    " curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/CascadiaCode.zip
    " curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hermit.zip
    " mkdir -p ~/.local/share/fonts/Cascadia ~/.local/share/fonts/Hermit
    " mv CascadiaCode.zip ~/.local/share/fonts/Cascadia/
    " mv Hermit.zip ~/.local/share/fonts/Hermit
    " cd ~/.local/share/fonts/Cascadia && unzip CascadiaCode.zip
    " cd ~/.local/share/fonts/Hermit && unzip Hermit.zip
    " cd ~ && fc-cache -fv 

  " YouCompleteMe a code-completion engine for Vim
  " you must install some dependecies manually:
  " https://github.com/ycm-core/YouCompleteMe#linux-64-bit
  " https://vimawesome.com/plugin/youcompleteme#python-semantic-completion
  " Plug 'valloric/youcompleteme'

  " tabline plugin with re-orderable, auto-sizing, clickable tabs, icons,
  " nice highlighting, sort-by commands and a magic jump-to-buffer mode
  " Plus the tab names are made unique when two filenames match.
  " https://github.com/romgrk/barbar.nvim
    Plug 'romgrk/barbar.nvim'

  " vim-visual-multi - multiline editing
  " It's called vim-visual-multi in analogy with visual-block
  " but the plugin works mostly from normal mode.
  " https://github.com/mg979/vim-visual-multi
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}

  " vscode.nvim (formerly codedark.nvim) is a Lua port of vim-code-dark colorscheme 
  " for neovim with VScode's light and dark theme
  " https://github.com/Mofiqul/vscode.nvim
    Plug 'Mofiqul/vscode.nvim'

  " A snazzy buffer line (with tabpage integration) for Neovim built using lua.
  " it's need nvim-tree/nvim-web-devicons
  " https://github.com/akinsho/bufferline.nvim
  " Plug 'ryanoasis/vim-devicons' Icons without colours
    Plug 'akinsho/bufferline.nvim', { 'tag': '*' }

  " A Vim plugin which shows a git diff in the sign column.
  " https://github.com/airblade/vim-gitgutter
    Plug 'airblade/vim-gitgutter'

  " A blazing fast and easy to configure Neovim statusline
  " it's need nvim-tree/nvim-web-devicons
  " https://github.com/nvim-lualine/lualine.nvim
    Plug 'nvim-lualine/lualine.nvim'

  " highly extendable fuzzy finder over lists. 
  " Built on the latest awesome features from neovim core. 
  " Telescope is centered around modularity, allowing for easy customization.
  " https://github.com/nvim-telescope/telescope.nvim
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }

  " The goal of nvim-treesitter is both to provide a simple and easy way 
  " to use the interface for tree-sitter in Neovim and to provide some 
  " basic functionality such as highlighting
  " https://github.com/nvim-treesitter/nvim-treesitter
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " nvim terminal - toggleterml
  " https://github.com/akinsho/toggleterm.nvim
    Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

  " NeoVIM customization section
    
    " set font for gui 
    " (if you want the same thing in console - you must change default consolefont)
    " (if you use ssh connection you must set nerd fonts on your local machine)
    " (windows - https://www.thewindowsclub.com/add-custom-fonts-to-command-prompt)
    " for recognize available fonts - use this command:
    " fc-list

      au VimEnter * lua vim.opt.guifont='Hurmit NF:style=bold'

    " loading lua scripts

      " vscode.nvim loading

        au VimEnter * lua vim.o.background = "dark"

        au VimEnter * lua require("vscode").setup({
	\
	\     local c = require("vscode.colors").get_colors()
	\
	\     transparent = true,
        \
        \     italic_comments = true,
        \
        \     disable_nvimtree_bg = true,
        \
        \     color_overrides = {
        \       vscLineNumber = '#FFFFFF',
        \     },
        \
        \     group_overrides = {  
        \       Cursor = {   
	\	  fg   = c.vscDarkBlue, 
	\	  bg   = c.vscLightGreen, 
	\	  bold = true 
	\	},
        \     }, 
        \ })

	au VimEnter * lua require("vscode").load()


      " bufferline loading

        au VimEnter * lua require("bufferline").setup({ 
          \ ioptions = {
	  \   buffer_close_icon = "",
          \   close_command = "bdelete %d",
          \   close_icon = "",
          \   indicator = {
	  \     style = "icon",
	  \     icon = " ",
          \   },
          \   left_trunc_marker = "",
          \   modified_icon = "●",
          \   offsets = { { filetype = "NvimTree", text = "EXPLORER", text_align = "center" } },
          \   right_mouse_command = "bdelete! %d",
          \   right_trunc_marker = "",
          \   show_close_icon = false,
          \   show_tab_indicators = true,
          \ },
          \ highlights = {
          \   fill = {
	  \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "StatusLineNC" },
          \   },
          \   background = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "StatusLine" },
          \   },
          \   buffer_visible = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "Normal" },
          \   },
          \   buffer_selected = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "Normal" },
          \   },
          \   separator = {
          \     fg = { attribute = "bg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "StatusLine" },
          \   },
          \   separator_selected = {
          \     fg = { attribute = "fg", highlight = "Special" },
          \     bg = { attribute = "bg", highlight = "Normal" },
          \   },
          \   separator_visible = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "StatusLineNC" },
          \   },
          \   close_button = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "StatusLine" },
          \   },
          \   close_button_selected = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "Normal" },
          \   },
          \   close_button_visible = {
          \     fg = { attribute = "fg", highlight = "Normal" },
          \     bg = { attribute = "bg", highlight = "Normal" },
          \   },
	  \ },
        \ })


      " lualine loading

        au VimEnter * lua require("lualine").setup({
        \  options = {
        \    theme = 'vscode'
        \  },
        \ })

      " toggleterm loading

        au VimEnter * lua require("toggleterm").setup()

	" toggleterm configuration
	
          " au VimEnter * lua require("toggleterm.config")
	  " au VimEnter * lua vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

      " nvimtree loading

        au VimEnter * lua require("nvim-tree").setup()

        " nvimtree configuration}
          " disable netrw at the very start of your init.lua (strongly advised)
          au VimEnter * lua vim.g.loaded_netrw = 1
          au VimEnter * lua vim.g.loaded_netrwPlugin = 1
          " set termguicolors to enable highlight groups
          au VimEnter * lua vim.opt.termguicolors = true

    " startup

      " display code line numbers by default
        set number

      " install plugins automatically
        autocmd VimEnter *
          \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
          \|   PlugInstall --sync | q
          \| endif

      " run neovim with nerd tree automatically
        " au VimEnter *  NERDTree<Down>

      " run nvim-tree automatically
        au VimEnter * NvimTreeToggle
        
    " shortcut mapping

        " insert mode shorcuts
          nnoremap <C-s> :w\|bd<CR> 

        " set paste shorcut (Ctrl + Shift + V)
          " set paste

        " vim panes switching
          " map  <C-l> :tabn<CR>        " Ctrl + l
          " map  <C-h> :tabp<CR>        " Ctrl + h
          " map  <C-n> :tabnew<CR>      " Ctrl + n

        " panes switching (default)
        " Ctrl + w w cycle though all windows
        " Ctrl + w h takes you left a window
        " Ctrl + w j takes you down a window
        " Ctrl + w k takes you up a window
        " Ctrl + w l takes you right a window

        " NvimTree shortcuts
          map <C-b> :NvimTreeToggle<CR>

          " files

            " a - (add) allows the creation of files or folders, creating a folder is done by following the name with the slash /.
              " E.g. /nvchad/nvimtree.md will create the related markdown file while /nvchad/nvimtree/ will create the nvimtree 
              " folder. The creation will occur by default at the location where the cursor is in the file explorer at that time,
              " so the selection of the folder where to create the file will have to be done previously or alternatively 
              " you can write the full path in the statusline, in writing the path you can make use of the auto-complete function
            " Ctrl + r - to rename the file regardless of its original name
            " d - (delete) to delete the selected file or in case of a folder delete the folder with all its contents
            " x - (cut) to cut and copy the selection to the clipboard, can be files or folders with all its contents,
              " with this command associated with the paste command you make the file moves within the tree
            " c - (copy) like the previous command this copies the file to the clipboard but keeps the original file in its location
            " p - (paste) to paste the contents of the clipboard to the current location
            " y - to copy only the file name to the clipboard
            " Y - to copy the relative path
            " g + y - to copy the absolute path
          
          " opening modes

            " Enter - open as normal without splitting
            " Tab - to open the file in a new buffer while keeping the cursor in `nvimtree`, 
              " this for example is useful if you want to open several files at once
            " Ctrl + t - open file in new tab that can be managed separately from the other buffers present
            " Ctrl + v -  to open the file in the buffer by dividing it vertically into two parts, 
              " if there was already an open file this will be displayed side by side with the new file
            " Ctrl + x - to open the file like the command described above but dividing the buffer horizontally
	
	" BarBar shortcuts
	" https://github.com/romgrk/barbar.nvim
	
	  " Move to previous/next
		
	    nnoremap <silent>    <A-,> <Cmd>BufferPrevious<CR>
	    nnoremap <silent>    <A-.> <Cmd>BufferNext<CR>

	  " Re-order to previous/next
	    
	    nnoremap <silent>    <A-<> <Cmd>BufferMovePrevious<CR>
	    nnoremap <silent>    <A->> <Cmd>BufferMoveNext<CR>

	  " Goto buffer in position...
	     
	    nnoremap <silent>    <A-1> <Cmd>BufferGoto 1<CR>
	    nnoremap <silent>    <A-2> <Cmd>BufferGoto 2<CR>
	    nnoremap <silent>    <A-3> <Cmd>BufferGoto 3<CR>
	    nnoremap <silent>    <A-4> <Cmd>BufferGoto 4<CR>
	    nnoremap <silent>    <A-5> <Cmd>BufferGoto 5<CR>
	    nnoremap <silent>    <A-6> <Cmd>BufferGoto 6<CR>
	    nnoremap <silent>    <A-7> <Cmd>BufferGoto 7<CR>
	    nnoremap <silent>    <A-8> <Cmd>BufferGoto 8<CR>
	    nnoremap <silent>    <A-9> <Cmd>BufferGoto 9<CR>
	    nnoremap <silent>    <A-0> <Cmd>BufferLast<CR>

	  " Pin/unpin buffer
	    
	    nnoremap <silent>    <A-p> <Cmd>BufferPin<CR>

  	  " Close buffer
	
	    nnoremap <silent>    <A-c> <Cmd>BufferClose<CR>
	
	  " Restore buffer
	
	    nnoremap <silent>    <A-s-c> <Cmd>BufferRestore<CR>

          " Wipeout buffer
	  "                          :BufferWipeout
	  " Close commands
	  "                          :BufferCloseAllButCurrent
	  "                          :BufferCloseAllButVisible
	  "                          :BufferCloseAllButPinned
	  "                          :BufferCloseAllButCurrentOrPinned
	  "                          :BufferCloseBuffersLeft
	  "                          :BufferCloseBuffersRight

	  " Magic buffer-picking mode
	
	    nnoremap <silent> <C-p>    <Cmd>BufferPick<CR>
	    nnoremap <silent> <C-p>    <Cmd>BufferPickDelete<CR>

	  " Sort automatically by...
	
	    nnoremap <silent> <Space>bb <Cmd>BufferOrderByBufferNumber<CR>
	    nnoremap <silent> <Space>bd <Cmd>BufferOrderByDirectory<CR>
	    nnoremap <silent> <Space>bl <Cmd>BufferOrderByLanguage<CR>
	    nnoremap <silent> <Space>bw <Cmd>BufferOrderByWindowNumber<CR>

	  " Other:
	  " :BarbarEnable - enables barbar (enabled by default)
	  " :BarbarDisable - very bad command, should never be used
        
	" ToggleTerm shortcuts
	
	  autocmd TermEnter term://*toggleterm#*
            \ tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>

	  nnoremap <silent> <A-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
          inoremap <silent> <A-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

	  " Ctrl + \ + Ctrl + n - exit form terminal mode

	" vim-visual-multi - multiline editing shortcuts
	" https://github.com/mg979/vim-visual-multi/wiki/Quick-start
	
	  " ESC - exit mode                          
	  " Ctrl + n - select the word under cursor
	  " Ctrl + n - from visual mode, without word boundaries
	  " Ctrl + Down - create cursors vertically down (works on normal mode only)
	  " Ctrl + Up - create cursors vertically up (works on normal mode only)
	  " Q - remove region (cusrsor) (works on normal mode only)
	  " n / N / q - Next / Previous / Skip (works on normal mode only)
	  " \\A - select all occurences of word      
	  " \\/ - create section with regex search
	  " \\\ - add single cursor at current position
	  " \\gS - reselect set of regions of last VM session

	  " Ctrl + LeftMouse - create a cursor where clicked
	  " Ctrl + RightMouse - select a word where clicked
	  " Alt + Ctrl + RightMouse - create column, from current cursot to clicekd position

	" Additional shortcut stuff
	
	  " add some keybindings for - copy / paste / cut (visual mode)
	  " fix vim-visual-multi (select lines is throuble with Ctrl + n)
	  " repair Ctrl + v NvimTree Error (it working by ssh via CMD but it
	  " doesn't work via VSC integrated terminal - reason can be in Ctrl +
	  " v binding usage - VSC not apply shotcuts like that and Nvim gets
	  " errors)

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting
