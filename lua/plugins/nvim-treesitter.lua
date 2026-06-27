return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function () 
      local configs = require("nvim-treesitter")

      configs.setup({
        -- A list of parser names, or "all"
        ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "typescript", "python", "markdown", "bash", "css", "html", "dart", "godot_resource", "c_sharp", "go" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        highlight = {
          enable = true,
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end
}
