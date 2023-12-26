return {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            -- NOTE: If you are having trouble with this installation,
            --       refer to the README for telescope-fzf-native for more instructions.
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        {
            "nvim-telescope/telescope-ui-select.nvim",
            config = function()
                local telescope = require("telescope")
                telescope.setup {
                    extensions = {
                        ["ui-select"] = {
                            require("telescope.themes").get_dropdown {
                                -- even more opts
                            }

                            -- pseudo code / specification for writing custom displays, like the one
                            -- for "codeactions"
                            -- specific_opts = {
                            --   [kind] = {
                            --     make_indexed = function(items) -> indexed_items, width,
                            --     make_displayer = function(widths) -> displayer
                            --     make_display = function(displayer) -> function(e)
                            --     make_ordinal = function(e) -> string
                            --   },
                            --   -- for example to disable the custom builtin "codeactions" display
                            --      do the following
                            --   codeactions = false,
                            -- }
                        }
                    }
                }
                telescope.load_extension("ui-select")
            end,
        },
    },
    config = function()
        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        local telescope = require("telescope")
        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-u>'] = false,
                        ['<C-d>'] = false,
                    },
                },
            },
        }

        -- Enable telescope fzf native, if installed
        pcall(telescope.load_extension, 'fzf')

        -- See `:help telescope.builtin`
        vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })


        -- Telescope
        local status, telescope_builtin = pcall(require, "telescope.builtin")
        if status then
            vim.keymap.set('n', '<leader>gf', telescope_builtin.git_files, { desc = 'Search [G]it [F]iles' })
            vim.keymap.set('n', '<leader>sf', telescope_builtin.find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>sh', telescope_builtin.help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sw', telescope_builtin.grep_string, { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sg', telescope_builtin.live_grep, { desc = '[S]earch by [G]rep' })
            vim.keymap.set('n', '<leader>sd', telescope_builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = '[F]ind [F]iles' })
            vim.keymap.set('n', '<leader>pf', telescope_builtin.find_files)
            vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = '[F]ind by [G]rep' })
            vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers)
            vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags)
            vim.keymap.set("n", "<leader>gs", telescope_builtin.git_status, { desc = '[G]it [S]tatus' })
            vim.keymap.set("n", "<leader>gc", telescope_builtin.git_commits, { desc = '[G]it [C]ommits' })
            vim.keymap.set('n', '<C-p>', telescope_builtin.git_files)
            vim.keymap.set('n', '<leader>ps', function()
                telescope_builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        else
            print("Telescope not found")
        end
    end,
}
