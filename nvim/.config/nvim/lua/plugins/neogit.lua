return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	cmd = "Neogit",
	init = function()
		vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>", { desc = "Open Neogit" })
	end,
	config = function()
		require("neogit").setup({
			kind = "split",
			disable_signs = false,
			disable_hint = false,

			commit_popup = {
				kind = "split",
			},
			popup = {
				kind = "split",
			},
		})
	end,
}
