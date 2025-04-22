return {
	"theprimeagen/harpoon",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")

		vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: Add file to list" })
		vim.keymap.set("n", "<leader>h", mark.toggle_file, { desc = "Harpoon: Toggle current file" })

		vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon: Toggle quick menu" })

		vim.keymap.set("n", "<A-6>", function()
			ui.nav_file(1)
		end, { desc = "Harpoon: Go to file 1" })
		vim.keymap.set("n", "<A-7>", function()
			ui.nav_file(2)
		end, { desc = "Harpoon: Go to file 2" })
		vim.keymap.set("n", "<A-8>", function()
			ui.nav_file(3)
		end, { desc = "Harpoon: Go to file 3" })
		vim.keymap.set("n", "<A-9>", function()
			ui.nav_file(4)
		end, { desc = "Harpoon: Go to file 4" })
	end,
}
