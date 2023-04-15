require("tokyonight").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "day", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
})

-- vim.api.nvim_set_hl(0, "Normal", { bg = "white" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- Lua
vim.cmd[[colorscheme tokyonight]]
