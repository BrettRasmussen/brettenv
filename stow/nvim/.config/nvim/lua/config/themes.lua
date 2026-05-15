-- This file contains a collection of 50 modern, LSP-compatible themes.
-- To try a theme, uncomment its block and the vim.cmd("colorscheme ...") line.
-- Make sure only ONE colorscheme command is active at a time.

local themes = {
  -- --- THE EVERFOREST FAMILY & ADJACENT ---
  -- { "comfysage/evergarden", config = function() require("evergarden").setup({ transparent_background = true }); vim.cmd.colorscheme("evergarden") end },
  -- { "sainnhe/gruvbox-material", config = function() vim.g.gruvbox_material_background = "hard"; vim.g.gruvbox_material_transparent_background = 1; vim.cmd.colorscheme("gruvbox-material") end },
  { "sainnhe/sonokai", config = function() vim.g.sonokai_style = "espresso"; vim.g.sonokai_transparent_background = 1; vim.cmd.colorscheme("sonokai") end },
  -- { "sainnhe/edge", config = function() vim.g.edge_style = "aura"; vim.g.edge_transparent_background = 1; vim.cmd.colorscheme("edge") end },
  -- { "ribru17/bamboo.nvim", config = function() require("bamboo").setup({ transparent = true }); vim.cmd.colorscheme("bamboo") end },

  -- --- THE "BIG THREE" (Most Robust LSP Support) ---
  -- { "folke/tokyonight.nvim", config = function() require("tokyonight").setup({ style = "storm", transparent = true }); vim.cmd.colorscheme("tokyonight") end },
  -- { "catppuccin/nvim", name = "catppuccin", config = function() require("catppuccin").setup({ flavour = "mocha", transparent_background = true }); vim.cmd.colorscheme("catppuccin") end },
  -- { "rebelot/kanagawa.nvim", config = function() require("kanagawa").setup({ transparent = true }); vim.cmd.colorscheme("kanagawa") end },

  -- --- POPULAR & MODERN ---
  -- { "EdenEast/nightfox.nvim", config = function() require("nightfox").setup({ options = { transparent = true } }); vim.cmd.colorscheme("carbonfox") end },
  -- { "rose-pine/neovim", name = "rose-pine", config = function() require("rose-pine").setup({ variant = "main", dark_variant = "main", disable_background = true }); vim.cmd.colorscheme("rose-pine") end },
  -- { "navarasu/onedark.nvim", config = function() require("onedark").setup({ style = "darker", transparent = true }); vim.cmd.colorscheme("onedark") end },
  -- { "rebelot/terminal.nvim", config = function() require("terminal").setup() end },
  -- { "shaunsingh/nord.nvim", config = function() vim.cmd.colorscheme("nord") end },
  -- { "marko-cerovac/material.nvim", config = function() vim.g.material_style = "deep ocean"; require("material").setup({ disable = { background = true } }); vim.cmd.colorscheme("material") end },
  -- { "olimorris/onedarkpro.nvim", config = function() require("onedarkpro").setup({ options = { transparency = true } }); vim.cmd.colorscheme("onedarkpro") end },
  -- { "Mofiqul/dracula.nvim", config = function() vim.cmd.colorscheme("dracula") end },
  -- { "nxvu699134/nuo.nvim" },
  -- { "tiagovla/tokyodark.nvim", config = function() vim.cmd.colorscheme("tokyodark") end },
  -- { "AstroNvim/astrotheme", config = function() vim.cmd.colorscheme("astrotheme") end },
  -- { "Everblush/nvim", name = "everblush", config = function() vim.cmd.colorscheme("everblush") end },
  -- { "folke/styler.nvim" },
  -- { "eldritch-theme/eldritch.nvim", config = function() require("eldritch").setup({ transparent = true }); vim.cmd.colorscheme("eldritch") end },
  -- { "scottmckendry/cyberdream.nvim", config = function() require("cyberdream").setup({ transparent = true }); vim.cmd.colorscheme("cyberdream") end },
  -- { "dgox16/oldworld.nvim", config = function() vim.cmd.colorscheme("oldworld") end },
  -- { "ramojus/mellifluous.nvim", config = function() require("mellifluous").setup({ transparent_background = { enabled = true } }); vim.cmd.colorscheme("mellifluous") end },
  -- { "kvrohit/mellow.nvim", config = function() vim.cmd.colorscheme("mellow") end },
  -- { "Yzeed/mxt.nvim" },
  -- { "oxfist/night-owl.nvim", config = function() require("night-owl").setup(); vim.cmd.colorscheme("night-owl") end },
  -- { "rmehri01/onenord.nvim", config = function() require("onenord").setup({ disable_background = true }); vim.cmd.colorscheme("onenord") end },
  -- { "AlexvZyl/nordic.nvim", config = function() require("nordic").setup({ transparent_bg = true }); vim.cmd.colorscheme("nordic") end },
  -- { "decaycs/decay.nvim", name = "decay", config = function() vim.cmd.colorscheme("decayce") end },
  -- { "luisiacc/gruvbox-baby", config = function() vim.g.gruvbox_baby_transparent_mode = 1; vim.cmd.colorscheme("gruvbox-baby") end },
  -- { "ofirgall/ofirkai.nvim", config = function() vim.cmd.colorscheme("ofirkai") end },
  -- { "titanzero/zephyrium", config = function() vim.cmd.colorscheme("zephyrium") end },
  -- { "Verf/deepwhite.nvim", config = function() vim.cmd.colorscheme("deepwhite") end },
  -- { "Tsuzat/Neogruv.nvim", config = function() vim.cmd.colorscheme("neogruv") end },
  -- { "baliestri/aura-theme", name = "aura", config = function() vim.cmd.colorscheme("aura") end },
  -- { "PHS7G/finerer-everforest.nvim", name = "finerer-everforest" },
  -- { "nuvic/flat.nvim", config = function() vim.cmd.colorscheme("flat") end },
  -- { "bluz71/vim-moonfly-colors", name = "moonfly", config = function() vim.cmd.colorscheme("moonfly") end },
  -- { "bluz71/vim-nightfly-colors", name = "nightfly", config = function() vim.cmd.colorscheme("nightfly") end },
  -- { "FrenzyExists/aquarium-vim", config = function() vim.cmd.colorscheme("aquarium") end },
  -- { "cryptomilk/nightcity.nvim", config = function() require("nightcity").setup({ style = "kabuki" }); vim.cmd.colorscheme("nightcity") end },
  -- { "NTBBloodbath/doom-one.nvim", config = function() vim.cmd.colorscheme("doom-one") end },
  -- { "projekt0n/github-nvim-theme", config = function() require("github-theme").setup(); vim.cmd.colorscheme("github_dark") end },
  -- { "Shatur/neovim-ayu", config = function() require("ayu").setup({ mirrored_sidebars = false }); vim.cmd.colorscheme("ayu-dark") end },
  -- { "dgox16/indiscret.nvim" },
  -- { "cdmill/neominimalist.nvim", config = function() require("neominimalist").setup({ transparent = true }); vim.cmd.colorscheme("neominimalist") end },
  -- { "Yazeed1s/minimal.nvim" },
  -- { "aliqyan-21/darkvoid.nvim", config = function() require("darkvoid").setup({ transparent = true }); vim.cmd.colorscheme("darkvoid") end },
}

return themes
