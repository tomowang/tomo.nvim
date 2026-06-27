return {
    'akinsho/toggleterm.nvim',
    commit = "b4b0dfc",
    -- version = "*",
    config = function ()
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 20
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
	})
    end
}
