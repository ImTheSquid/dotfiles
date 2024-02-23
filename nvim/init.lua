-- Keybinds
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>tt", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>tq", function() require("trouble").toggle("quickfix") end)

-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Setup language servers.
--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require('lspconfig')
lspconfig.pyright.setup {
    capabilities = capabilities,
}
lspconfig.tsserver.setup {
    capabilities = capabilities,
}
lspconfig.pest_ls.setup {
    capabilities = capabilities,
}
lspconfig.typst_lsp.setup{
  capabilities = capabilities,
	settings = {
		exportPdf = "onType" -- Choose onType, onSave or never.
        -- serverPath = "" -- Normally, there is no need to uncomment it.
	}
}
lspconfig.hls.setup{,
    capabilities = capabilities,
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
}
lspconfig.rust_analyzer.setup{
    capabilities = capabilities,
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
          command = "clippy";
        },
	check = {
	  command = "clippy";
	},
	cargo = {
	  features = "all";
  	},
    files = {
  excludeDirs = {
    "_build",
    ".dart_tool",
    ".flatpak-builder",
    ".git",
    ".gitlab",
    ".gitlab-ci",
    ".gradle",
    ".idea",
    ".next",
    ".project",
    ".scannerwork",
    ".settings",
    ".venv",
    ".vercel",
    "archetype-resources",
    "bin",
    "hooks",
    "node_modules",
    "po",
    "screenshots",
    "target"
}
    }

        }
    }
}

lspconfig.cssls.setup {
  capabilities = capabilities,
}

--require("mason").setup()
-- Treesitter Plugin Setup 
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "rust", "toml" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true }, 
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}

local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

vim.o.completeopt = "menuone,noinsert,noselect"

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

require("kanagawa").setup()

vim.cmd("colorscheme kanagawa")

-- File Explorer
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup({
    actions = {
        open_file = {
            resize_window=false
        }
    }
})

-- Line numbers
vim.cmd("set nu rnu")

-- Tabs
vim.cmd("set tabstop=4 shiftwidth=4 expandtab")

-- Telescope
require("telescope").setup()

-- Session manager
-- Auto save session
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  callback = function ()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- Don't save while there's any 'nofile' buffer open.
      if vim.api.nvim_get_option_value("buftype", { buf = buf }) == 'nofile' then
        return
      end
    end
    session_manager.save_current_session()
  end
})

vim.filetype.add({
    extension = {
        typ = 'typst',
        pest = 'pest',
    }
})
