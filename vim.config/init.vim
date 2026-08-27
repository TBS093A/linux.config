" nvim plugins

  " vim-plug bootstrap - stdpath('data') . '/site/autoload/plug.vim' is
  " where Neovim itself looks for autoload/plug#* functions (it does NOT
  " look in ~/.vim/autoload - that's classic Vim's path, and checking/
  " downloading there left plug#begin() undefined on any account that
  " never had vim-plug installed by some other means first).
    let s:plug_vim = stdpath('data') . '/site/autoload/plug.vim'
    if empty(glob(s:plug_vim))
      silent execute '!curl -fLo ' . s:plug_vim . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
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

  " Unmanaged plugin (manually installed and updated) - this was vim-plug's
  " own README example path, never swapped for a real plugin, and
  " ~/my-prototype-plugin doesn't exist. Left in, it makes g:plugs treat
  " a plugin as permanently missing, which re-triggers PlugInstall's
  " status window on every single startup - and that window is what was
  " hitting a treesitter nil-value crash on this nvim version.
  " Plug '~/my-prototype-plugin'

  " vim-workspace for create sessions
  " https://vimawesome.com/plugin/vim-workspace
    Plug 'thaerkh/vim-workspace'

" Highlights plugins

  " Jenkinsfile syntax highlighting
  " https://vimawesome.com/plugin/vim-jenkinsfile
    Plug 'thanethomson/vim-jenkinsfile'

" Visual Studio Code plugins

  " code formatter
  " https://github.com/mhartington/formatter.nvim
  Plug 'mhartington/formatter.nvim'

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

  " Copilot - AI completion
  " https://github.com/github/copilot.vim
  "  Plug 'github/copilot.vim'

  " YouCompleteMe a code-completion (C / C++ / Java) engine for Vim
  " you must install some dependecies manually:
  " https://github.com/ycm-core/YouCompleteMe#linux-64-bit
  " https://vimawesome.com/plugin/youcompleteme#python-semantic-completion
  " Plug 'valloric/youcompleteme'

  " Python code completion plugin - Jedi-vim
  " https://github.com/davidhalter/jedi-vim
    Plug 'davidhalter/jedi-vim'

  " jedi-vim not working with 'set paste' option,
  " disable it by 'set nopaste' for use this plugin

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

  " avante.nvim - Cursor-style AI sidebar: ask/edit against a selection,
  " get a diff back, accept/reject it in place. Claude/OpenAI/Grok all
  " configured below (nvim-lua/plenary.nvim above is a dep it shares with
  " telescope already).
  "
  " 'do' backgrounds `make` instead of running it inline: it downloads a
  " prebuilt binary for avante's small Rust component when one matches
  " the platform, but falls back to building one from source (needs
  " cargo - install.sh installs it alongside neovim, see cargo_pkg()
  " there) when it doesn't, and that fallback is NOT quick - verified by
  " hand, a cold from-source build ran 15-20+ minutes and over 1GB of
  " build artifacts on ordinary hardware. Worse, `timeout` in install.sh
  " can't bound that either - make/cargo fork children of their own that
  " don't reliably receive/forward its signal, so a blocking `do: 'make'`
  " here risks hanging install.sh's PlugInstall step well past any
  " timeout wrapped around it. Backgrounding it means install.sh always
  " finishes on schedule; avante just isn't usable until the build
  " catches up on its own - check ~/.cache/nvim/avante-nvim-build.log, or
  " just retry :AvanteAsk again in a few minutes on a first install.
  " https://github.com/yetone/avante.nvim
    Plug 'MunifTanjim/nui.nvim'
    Plug 'MeanderingProgrammer/render-markdown.nvim'
    Plug 'yetone/avante.nvim', { 'branch': 'main',
      \ 'do': 'mkdir -p ' . stdpath('cache') . ' && nohup make >' . stdpath('cache') . '/avante-nvim-build.log 2>&1 &' }

  " NeoVIM customization section

    " set font for gui
    " (if you want the same thing in console - you must change default consolefont)
    " (if you use ssh connection you must set nerd fonts on your local machine)
    " (windows - https://www.thewindowsclub.com/add-custom-fonts-to-command-prompt)
    " for recognize available fonts - use this command:
    " fc-list

      au VimEnter * lua vim.opt.guifont='Hurmit NF:style=bold'

  " mhartington/formatter.nvim
  " format after save

        augroup FormatAutogroup
            autocmd!
            autocmd BufWritePre * FormatWrite
            " Makefiles require literal tabs for recipe lines - retabbing them breaks `make`.
            autocmd BufWritePre * if &filetype != 'make' | silent! %s/\s\+$//ge | silent! %s/\t/    /ge | endif
        augroup END

    " loading lua scripts

    " mhartington/formatter.nvim loading
      " if you want customize formatter for other languages, check this link:
      " https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
    " and declare like python example:

    "au VimEnter * lua require('formatter').setup({
    "\   logging = false,
    "\   filetype = {
       "\     python = {
       "\       require('formatter.filetypes.python').black
       "\     },
    "\     ["*"] = {
    "\       require('formatter.filetypes.any').remove_trailing_whitespace
    "\     }
    "\   }
    "\ })


      " vscode.nvim loading

        au VimEnter * lua vim.o.background = "dark"

        au VimEnter * lua local c = require("vscode.colors").get_colors();
  \     require("vscode").setup({
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
  \    fg   = c.vscDarkBlue,
  \    bg   = c.vscLightGreen,
  \    bold = true
  \  },
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

      " render-markdown loading (avante's chat sidebar renders as
      " filetype "Avante" - included here so it gets the same treatment
      " as real markdown, not just .md files)

        au VimEnter * lua require("render-markdown").setup({ file_types = { "markdown", "Avante" } })

      " avante.nvim loading - sidebar needs the global statusline to
      " render correctly (see avante's own README). Its README's own
      " vim-plug snippet hooks setup() on the 'User avante.nvim' event
      " instead of VimEnter - verified by hand that this never fires
      " here: vim-plug only dispatches a generic 'User <plugin>' event
      " for LAZILY loaded plugins (Plug '...', { 'on': ... } / { 'for':
      " ... }), and this Plug line above has neither, so it loads eagerly
      " at plug#end() and that event never comes. VimEnter, same as
      " every other plugin in this file, actually fires.

        au VimEnter * lua vim.opt.laststatus = 3

      " a heredoc can't be glued onto the end of an `autocmd` line as its
      " command (tried that - E492 on every line inside it) - it has to
      " be its own top-level `lua << EOF` block, so the VimEnter hook is
      " registered from inside it instead, via the Lua API directly
        lua << EOF
        vim.api.nvim_create_autocmd('VimEnter', {
          callback = function()
            require('avante').setup({
              provider = "claude",
              providers = {
                -- ANTHROPIC_API_KEY - see zsh.config/.zshrc.local.example
                claude = {
                  endpoint = "https://api.anthropic.com",
                  model = "claude-sonnet-5",
                  extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 8192,
                  },
                },
                -- OPENAI_API_KEY - see zsh.config/.zshrc.local.example.
                -- Model name goes stale fast; swap for whatever you
                -- actually have access to (:AvanteModels lists what
                -- avante knows about)
                openai = {
                  endpoint = "https://api.openai.com/v1",
                  model = "gpt-4o",
                  extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 8192,
                  },
                },
                -- Grok isn't a built-in avante provider, but xAI's API is
                -- OpenAI-compatible, so __inherited_from = "openai" wires
                -- it up the same way avante's own docs do for
                -- openrouter/groq/deepseek/etc. XAI_API_KEY - see
                -- .zshrc.local.example; check
                -- https://docs.x.ai/docs/models for a model your account
                -- actually has access to
                grok = {
                  __inherited_from = "openai",
                  api_key_name = "XAI_API_KEY",
                  endpoint = "https://api.x.ai/v1",
                  model = "grok-4",
                },
              },
            })
          end,
        })
EOF

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

    " jedi-vim configuration

      let g:jedi#use_tabs_not_buffers = 1
      let g:jedi#use_splits_not_buffers = "left"
      let g:jedi#environment_path = "/usr/bin/python3"

    " Copilot configuration (disabled - Plug 'github/copilot.vim' above is
    " commented out too; re-enable both together if you want it back)

      " au VimEnter * Copilot setup

    " startup

      " display code line numbers by default
        set number

      " set paste from host system in insert mode (Ctrl + Shift + V)
        set paste

      " set tab size
        set tabstop=4
    set shiftwidth=4
    set expandtab

      " install plugins automatically
        autocmd VimEnter *
          \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
          \|   PlugInstall --sync | q
          \| endif

      " run neovim with nerd tree automatically
        " au VimEnter *  NERDTree<Down>

      " auto-open UI on startup, in this order: terminal, tree, avante,
      " then focus back on the editor - not the last thing opened, which
      " is where it'd otherwise land. Order matters here, not just
      " cosmetically - ToggleTerm splits whatever window is currently
      " focused, so it has to fire first, while that's still the one
      " single full-width buffer nvim opened with; NvimTreeToggle/
      " AvanteToggle each carve out their own dedicated sidebar column
      " (left/right) regardless of focus, so their relative order
      " doesn't have the same constraint. All three plugins' own setup()
      " calls above are registered earlier in this file, so they've
      " already run by the time this fires (Neovim runs same-event
      " autocmds in registration order) - a single autocmd, not three,
      " so the editor window handle can be captured before any of this
      " opens and restored after, rather than guessing at it positionally
      " (`wincmd t`/`w` would land on whichever of tree/editor/avante
      " ends up visually top-left/first, not reliably the editor).
        lua << EOF
        vim.api.nvim_create_autocmd('VimEnter', {
          callback = function()
            local editor_win = vim.api.nvim_get_current_win()
            vim.cmd('ToggleTerm')
            vim.cmd('NvimTreeToggle')
            vim.cmd('AvanteToggle')
            vim.api.nvim_set_current_win(editor_win)
          end,
        })
EOF

    " shortcut mapping

        " insert mode shorcuts
          nnoremap <C-s> :w\|bd<CR>

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

        " jump straight to a named pane instead of hunting for it with
        " h/j/k/l - each opens that pane first if it isn't already, so
        " these always land somewhere rather than doing nothing. Note
        " Ctrl-w T and Ctrl-w F both shadow real (if obscure) nvim
        " defaults - move window to new tab, and edit file-under-cursor
        " in a new tab, respectively - a deliberate trade, chosen for
        " this layout's 4 named panes over those two rarely-used ones.
        "   Ctrl-w F        - the file tree (NvimTree)
        "   Ctrl-w T        - the terminal
        "   Ctrl-w C        - avante (its input if open, else its chat)
        "   Ctrl-w E        - the editor - first one, top-left, if split
        "   Ctrl-w E1..E9   - that specific editor split, same ordering
        lua << EOF
        local function find_win(pred)
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if pred(vim.api.nvim_win_get_buf(w)) then return w end
          end
        end

        local function jump_or_open(pred, open_cmd)
          local w = find_win(pred)
          if not w then
            vim.cmd(open_cmd)
            w = find_win(pred)
          end
          if w then vim.api.nvim_set_current_win(w) end
        end

        -- everything that isn't tree/avante's own panes and isn't a
        -- terminal counts as "editor", sorted top-to-bottom then
        -- left-to-right so E/E1 is always the top-left-most split
        local EDITOR_EXCLUDE = { NvimTree = true, Avante = true, AvanteInput = true, AvanteSelectedFiles = true }
        local function editor_wins()
          local wins = {}
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(w)
            if vim.bo[buf].buftype == '' and not EDITOR_EXCLUDE[vim.bo[buf].filetype] then
              table.insert(wins, w)
            end
          end
          table.sort(wins, function(a, b)
            local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
            if pa[1] ~= pb[1] then return pa[1] < pb[1] end
            return pa[2] < pb[2]
          end)
          return wins
        end

        vim.keymap.set('n', '<C-w>F', function()
          jump_or_open(function(b) return vim.bo[b].filetype == 'NvimTree' end, 'NvimTreeOpen')
        end, { silent = true, desc = 'Jump to the file tree' })

        vim.keymap.set('n', '<C-w>T', function()
          jump_or_open(function(b) return vim.bo[b].buftype == 'terminal' end, 'ToggleTerm')
        end, { silent = true, desc = 'Jump to the terminal' })

        vim.keymap.set('n', '<C-w>C', function()
          jump_or_open(function(b)
            local ft = vim.bo[b].filetype
            return ft == 'AvanteInput' or ft == 'Avante'
          end, 'AvanteToggle')
        end, { silent = true, desc = 'Jump to avante' })

        vim.keymap.set('n', '<C-w>E', function()
          local w = editor_wins()[1]
          if w then vim.api.nvim_set_current_win(w) end
        end, { silent = true, desc = 'Jump to the first (top-left) editor split' })

        for i = 1, 9 do
          vim.keymap.set('n', '<C-w>E' .. i, function()
            local wins = editor_wins()
            local w = wins[i] or wins[1]
            if w then vim.api.nvim_set_current_win(w) end
          end, { silent = true, desc = 'Jump to editor split #' .. i })
        end
EOF

        " NvimTree shortcuts
          map <C-b> :NvimTreeToggle<CR>

          " files

            " H - shows or hides hidden files
      " I - show ignored files by .gitignore

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
    " a - terminal mode (when terminal pane is selected)

    " Jedi-vim shortcuts (:help jedi-vim)

      " g:jedi#completions_command Ctrl + Space

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

    " Hold Shift + RightMouseClick (and mouse move for text select) + Enter - copy from vim / nvim to shitty windows clipboard
          " Ctrl + Shift + V - paste from windows clipboard
    " y - copy from visual mode (after select text (from text editor &
    " terminal also))
    " d - cut --"--
    " P - paste before cursor (normal mode or visual mode (when you want
    " replace something)
    " p - paste after cursor (normal mode or visual mode (when you want
    " replace something)

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
