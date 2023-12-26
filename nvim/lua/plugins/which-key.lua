return {
    "folke/which-key.nvim",
    opts = {},
    config = function()
        local config = require("configs.which-key")
        require("which-key").setup(config)
    end,
}
