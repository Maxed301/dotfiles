return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	defaults = {
		preview = {
			filesize_limit = 0.5555,
		},
	},

	config = function()
		local telescope = require("telescope")
		telescope.setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		local map = vim.keymap.set

		map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		map("n", "<leader>le", function()
			builtin.diagnostics({ severity = vim.diagnostic.severity.ERROR })
		end, { desc = "[S]earch [E]rrors", silent = true })
		map("n", "<leader>qf", builtin.quickfix, { desc = "[Q]uickfix [F]ill", silent = true })
		map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." repeat)' })
		map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		map("n", "<leader>td", ":TodoTelescope<CR>")
		map("n", "<leader>sm", function()
			builtin.lsp_document_symbols({ symbols = { "function" } })
		end, { desc = "[S]earch [M]ethods in file" })

		map("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(
				require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
			)
		end, { desc = "[/] Fuzzily search in current buffer" })
		map("n", "<leader>s/", function()
			builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
		end, { desc = "[S]earch [/] in Open Files" })
		map("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
		map("n", "<leader>le", function()
			require("telescope.builtin").diagnostics({ severity = vim.diagnostic.severity.ERROR })
		end, { desc = "Show [L]SP [E]rrors", silent = true })

		local colors = require("config.palette")
		local Highlights = {
			TelescopeMatching = { fg = colors.magenta2 },
			TelescopeSelection = { fg = colors.magenta, bg = "NONE", bold = true },
			TelescopePromptPrefix = { bg = "NONE" },
			TelescopePromptNormal = { bg = "NONE" },
			TelescopeResultsNormal = { bg = "NONE" },
			TelescopePreviewNormal = { bg = "NONE" },
			TelescopePromptBorder = { bg = "NONE", fg = colors.magenta },
			TelescopeResultsBorder = { bg = "NONE", fg = colors.magenta },
			TelescopePreviewBorder = { bg = "NONE", fg = colors.magenta },
			TelescopePromptTitle = { bg = "NONE", fg = colors.magenta },
			TelescopeResultsTitle = { bg = "NONE" },
			TelescopePreviewTitle = { bg = "NONE", fg = colors.magenta },
		}

		local function apply_highlights()
			for group, opts in pairs(Highlights) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end

		apply_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_highlights })
	end,
}
