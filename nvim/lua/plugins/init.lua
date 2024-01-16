return {
  "nvim-treesitter/nvim-treesitter",
  {"williamboman/mason.nvim", opts = {}},
  {"williamboman/mason-lspconfig.nvim", opts = {}},
  "neovim/nvim-lspconfig",
  "simrat39/rust-tools.nvim",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "dcampos/nvim-snippy",
  "rebelot/kanagawa.nvim",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  { 'gen740/SmoothCursor.nvim',
    config = function()
      require('smoothcursor').setup()
    end
  },
  {
  "j-hui/fidget.nvim",
  config = function()
    require("fidget").setup()
  end,
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
  {
    'Shatur/neovim-session-manager',
    config = function()
        require('session_manager').setup({})
    end,
  },
  {
      'numToStr/Comment.nvim',
      config = function()
          require('Comment').setup()
      end,
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup()
    end,
  }
}
