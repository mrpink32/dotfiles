-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    use {
        'theprimeagen/harpoon',
    }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }

    -- codeium
    use {
        'Exafunction/codeium.vim',
    }

    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    }

    -- use {
    --     'nvim-tree/nvim-tree.lua',
    --     requires = {
    --         'nvim-tree/nvim-web-devicons',
    --     }
    -- }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    use {
        "folke/which-key.nvim",
    }

    use {
        'folke/tokyonight.nvim',
        as = 'tokyonight',
    }

    -- use {
    --     'glepnir/dashboard-nvim',
    --     event = 'VimEnter',
    --     config = function() require('dashboard').setup({
    --         theme = 'hyper',
    --         config = {
    --             week_header = {
    --                 enable = true,
    --             },
    --             shortcut = {
    --                 { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
    --                 {
    --                     icon = ' ',
    --                     icon_hl = '@variable',
    --                     desc = 'Files',
    --                     group = 'Label',
    --                     action = 'Telescope find_files',
    --                     key = 'f',
    --                 },
    --                 {
    --                     desc = ' Apps',
    --                     group = 'DiagnosticHint',
    --                     action = 'Telescope app',
    --                     key = 'a',
    --                 },
    --                 {
    --                     desc = ' dotfiles',
    --                     group = 'Number',
    --                     action = 'Telescope dotfiles',
    --                     key = 'd',
    --                 },
    --             },
    --         },
    --     })
    --     end,
    --     requires = {'nvim-tree/nvim-web-devicons'},
    -- }

end)

