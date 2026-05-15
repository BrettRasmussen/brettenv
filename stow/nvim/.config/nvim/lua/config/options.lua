local opt = vim.opt

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.cursorline = true
opt.number = true
opt.signcolumn = "number"
opt.scrolloff = 5
opt.guicursor = "a:blinkon0,i:ver25-iCursor"
opt.showbreak = "--> "

-- Whitespace Visibility
opt.list = true
opt.listchars = { trail = "·", tab = "» " }

-- Search & Selection
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.shortmess:append("S")

-- Buffers & Tabs
opt.hidden = true
opt.confirm = true
opt.laststatus = 2
opt.showmode = true

-- Folding
opt.foldmethod = "indent"
opt.foldlevel = 1000

-- Formatting & Lists
opt.autoindent = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.textwidth = 100
opt.backspace = "2"

-- Native List/Bullet Handling
opt.formatoptions = "tcrqnj"
opt.breakindent = true
opt.formatlistpat = [[^\s*[0-9\.\-\+\*]\+\s\+]]

-- Suffixes to de-prioritize
opt.suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc"

-- Initialize Custom UI
require("utils.ui").setup()

-- Disable re-indenting on type (prevents jumping around)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.indentkeys = ""
    vim.opt_local.cinkeys = ""
    -- Ensure smartindent/cindent aren't overriding your manual choices
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
    end,
    })

    -- Native Filetype Detection (Ported from old setup)
    vim.filetype.add({
    extension = {
    dockerfile = "dockerfile",
    },
    pattern = {
    ["Dockerfile%..*"] = "dockerfile",
    ["dkr%..*"] = "bash",
    },
    })