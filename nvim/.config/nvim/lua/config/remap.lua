vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<leader>w", "<cmd>:w<CR>")

vim.keymap.set("n", "<A-,>", "<C-w>5<")
vim.keymap.set("n", "<A-.>", "<C-w>5>")
vim.keymap.set("n", "<A-/>", "<C-w>+")
vim.keymap.set("n", "<A-]>", "<C-w>-")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "]g", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end)

vim.keymap.set("n", "[g", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end)

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

vim.api.nvim_set_keymap(
	"n",
	"<Leader>ii",
	':lua vim.cmd("DiagnosticsToggleVirtualText")<CR>',
	{ noremap = true, silent = true }
)

vim.api.nvim_set_keymap("n", "<Leader>id", ':lua vim.cmd("DiagnosticsToggle")<CR>', { noremap = true, silent = true })
