-- nvim
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- keep buffer after replace
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- buffer command shortcuts
vim.keymap.set("n", "<leader>bn", ":bn<CR>")
vim.keymap.set("n", "<leader>bp", ":bp<CR>")
vim.keymap.set("n", "<leader>bd", ":bd<CR>")

-- vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })





-- harpoon
local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>a', mark.add_file)
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
vim.keymap.set('n', '<C-t>', function() ui.nav_file(2) end)
vim.keymap.set('n', '<C-n>', function() ui.nav_file(3) end)
vim.keymap.set('n', '<C-s>', function() ui.nav_file(4) end)



-- which-key
vim.o.timeout = true
vim.o.timeoutlen = 300



-- codeium
-- Change '<C-g>' here to any keycode you like.
vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true })
vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
vim.keymap.set('i', '<C-Bslash>', function() return vim.fn['codeium#Complete']() end, { expr = true })

-- Telescope
local status, telescope = pcall(require, "telescope.builtin")
if status then
    vim.keymap.set("n", "<leader>ff", telescope.find_files)
    vim.keymap.set('n', '<leader>pf', telescope.find_files)
    vim.keymap.set("n", "<leader>fg", telescope.live_grep)
    vim.keymap.set("n", "<leader>fb", telescope.buffers)
    vim.keymap.set("n", "<leader>fh", telescope.help_tags)
    vim.keymap.set("n", "<leader>fs", telescope.git_status)
    vim.keymap.set("n", "<leader>fc", telescope.git_commits)
    vim.keymap.set('n', '<C-p>', telescope.git_files)
    vim.keymap.set('n', '<leader>ps', function()
        telescope.grep_string({ search = vim.fn.input("Grep > ") })
    end)
else
    print("Telescope not found")
end

-- <leader> = the space key

-- Save
-- map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
-- map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
-- map("i", "jk", "<ESC>")

-- Windows
-- map("n", "<leader>ñ", "<CMD>vsplit<CR>")
-- map("n", "<leader>p", "<CMD>split<CR>")

-- NeoTree
-- map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
-- map("n", "<leader>o", "<CMD>Neotree focus<CR>")

-- Buffer
-- map("n", "<TAB>", "<CMD>bnext<CR>")
-- map("n", "<S-TAB>", "<CMD>bprevious<CR>")

-- Terminal
-- map("n", "<leader>th", "<CMD>ToggleTerm size=10 direction=horizontal<CR>")
-- map("n", "<leader>tv", "<CMD>ToggleTerm size=80 direction=vertical<CR>")

-- Markdown Preview
-- map("n", "<leader>m", "<CMD>MarkdownPreview<CR>")
-- map("n", "<leader>mn", "<CMD>MarkdownPreviewStop<CR>")

-- Window Navigation
-- map("n", "<C-h>", "<C-w>h")
-- map("n", "<C-l>", "<C-w>l")
-- map("n", "<C-k>", "<C-w>k")
-- map("n", "<C-j>", "<C-w>j")

-- Resize Windows
-- map("n", "<C-Left>", "<C-w><")
-- map("n", "<C-Right>", "<C-w>>")
-- map("n", "<C-Up>", "<C-w>+")
-- map("n", "<C-Down>", "<C-w>-")





