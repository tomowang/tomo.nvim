return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
        view={
            width = 40,
	},
	filters = {
            git_ignored = false, -- Set to false to show git-ignored files
            dotfiles = false,    -- Set to false to show hidden dotfiles
        },
    })
  end,
}
