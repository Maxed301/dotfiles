require("virt-column").setup({
	char = "X",
	highlight = "VirtColHighlight",
})
local magenta = "#bb9af7"
local black = "#000000"
vim.api.nvim_set_hl(0, "VirtColHighlight", { bg = black, fg = magenta })
