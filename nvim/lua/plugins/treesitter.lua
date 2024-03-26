return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
        require("nvim-treesitter.configs").setup(require("configs.treesitter"))
        require("nvim-treesitter.install").compilers = { "clang" }
    end,
}
