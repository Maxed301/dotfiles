return {
	"dmtrKovalenko/fff.nvim",
	lazy = false,
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	config = function()
		local fff = require("fff")
		local map = vim.keymap.set
		local colors = require("config.palette")

		fff.setup({
			prompt = ">> ",
			hl = {
				border = "FloatBorder",
				normal = "Normal",
				cursor = "CursorLine",
				matched = "IncSearch",
				title = "Title",
				prompt = "Question",
				frecency = "Number",
				debug = "Comment",
				combo_header = "Number",
				scrollbar = "Comment",
				directory_path = "Comment",
				selected = "FFFSelected",
				selected_active = "FFFSelectedActive",
				grep_match = "IncSearch",
				grep_line_number = "LineNr",
				grep_regex_active = "DiagnosticInfo",
				grep_plain_active = "Comment",
				grep_fuzzy_active = "DiagnosticHint",
				suggestion_header = "WarningMsg",
			},
		})

		local highlights = {
			FFFSelected = { fg = "#ffffff", bg = colors.magenta, bold = true },
			FFFSelectedActive = { fg = "#ffffff", bg = colors.magenta2, bold = true },
		}

		local function apply_highlights()
			for group, opts in pairs(highlights) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end

		local function relative_path(path)
			if path == "" then
				return nil
			end

			return vim.fn.fnamemodify(path, ":.")
		end

		local function select_from(items, opts, on_choice)
			vim.ui.select(items, opts, function(choice)
				if choice then
					on_choice(choice)
				end
			end)
		end

		local function listed_buffers()
			local items = {}

			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[bufnr].buflisted then
					local name = vim.api.nvim_buf_get_name(bufnr)
					items[#items + 1] = {
						bufnr = bufnr,
						path = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]",
					}
				end
			end

			table.sort(items, function(a, b)
				return a.bufnr < b.bufnr
			end)

			return items
		end

		local function search_open_buffers()
			vim.ui.input({ prompt = "Grep open buffers: " }, function(input)
				if not input or input == "" then
					return
				end

				local items = {}
				for _, buffer in ipairs(listed_buffers()) do
					local lines = vim.api.nvim_buf_get_lines(buffer.bufnr, 0, -1, false)
					for lnum, line in ipairs(lines) do
						local start_col = line:find(input, 1, true)
						if start_col then
							items[#items + 1] = {
								bufnr = buffer.bufnr,
								filename = vim.api.nvim_buf_get_name(buffer.bufnr),
								lnum = lnum,
								col = start_col,
								text = line,
							}
						end
					end
				end

				vim.fn.setqflist({}, " ", {
					title = "Open buffers: " .. input,
					items = items,
				})
				vim.cmd.copen()
			end)
		end

		local function find_in_current_buffer()
			local path = relative_path(vim.api.nvim_buf_get_name(0))
			if not path then
				vim.notify("Current buffer has no file path", vim.log.levels.WARN)
				return
			end

			fff.live_grep({ query = path .. " " })
		end

		local function find_neovim_files()
			fff.find_files_in_dir(vim.fn.stdpath("config"))
		end

		local function show_help()
			local items = vim.fn.getcompletion("", "help")
			select_from(items, {
				prompt = "Help tags",
				format_item = function(item)
					return item
				end,
			}, function(choice)
				vim.cmd.help(choice)
			end)
		end

		local function show_keymaps()
			local items = {}
			for _, mode in ipairs({ "n", "v", "i", "x", "o", "c", "t" }) do
				for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
					items[#items + 1] = {
						mode = mode,
						lhs = keymap.lhs,
						desc = keymap.desc or keymap.rhs or "",
					}
				end
			end

			table.sort(items, function(a, b)
				return (a.mode .. a.lhs) < (b.mode .. b.lhs)
			end)

			select_from(items, {
				prompt = "Keymaps",
				format_item = function(item)
					return string.format("[%s] %s -> %s", item.mode, item.lhs, item.desc)
				end,
			}, function(choice)
				vim.notify(string.format("%s %s", choice.lhs, choice.desc), vim.log.levels.INFO)
			end)
		end

		local function show_recent_files()
			local items = {}
			for _, file in ipairs(vim.v.oldfiles) do
				if vim.fn.filereadable(file) == 1 then
					items[#items + 1] = file
				end
			end

			select_from(items, {
				prompt = "Recent files",
				format_item = function(item)
					return vim.fn.fnamemodify(item, ":.")
				end,
			}, function(choice)
				vim.cmd.edit(vim.fn.fnameescape(choice))
			end)
		end

		local function show_buffers()
			select_from(listed_buffers(), {
				prompt = "Buffers",
				format_item = function(item)
					return string.format("%d: %s", item.bufnr, item.path)
				end,
			}, function(choice)
				vim.api.nvim_set_current_buf(choice.bufnr)
			end)
		end

		local function show_diagnostics(severity)
			vim.diagnostic.setqflist({ severity = severity, open = true })
		end

		local function show_builtin_picker_menu()
			local items = {
				{ label = "files", action = fff.find_files },
				{ label = "grep", action = fff.live_grep },
				{ label = "buffers", action = show_buffers },
				{ label = "help", action = show_help },
				{ label = "recent files", action = show_recent_files },
				{ label = "diagnostics", action = function()
					show_diagnostics()
				end },
			}

			select_from(items, {
				prompt = "Search",
				format_item = function(item)
					return item.label
				end,
			}, function(choice)
				choice.action()
			end)
		end

		apply_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_highlights })

		map("n", "<leader>sh", show_help, { desc = "[S]earch [H]elp" })
		map("n", "<leader>sk", show_keymaps, { desc = "[S]earch [K]eymaps" })
		map("n", "<leader>sf", fff.find_files, { desc = "[S]earch [F]iles" })
		map("n", "<leader>ss", show_builtin_picker_menu, { desc = "[S]earch [S]elect" })
		map("n", "<leader>sw", function()
			fff.live_grep({ query = vim.fn.expand("<cword>") })
		end, { desc = "[S]earch current [W]ord" })
		map("n", "<leader>sg", fff.live_grep, { desc = "[S]earch by [G]rep" })
		map("n", "<leader>sd", "<cmd>Diagnostics<CR>", { desc = "[S]earch [D]iagnostics", silent = true })
		map("n", "<leader>le", "<cmd>LspErrors<CR>", { desc = "Show [L]SP [E]rrors", silent = true })
		map("n", "<leader>qf", "<cmd>copen<CR>", { desc = "[Q]uickfix [F]ill", silent = true })
		map("n", "<leader>sr", show_recent_files, { desc = "[S]earch [R]ecent files" })
		map("n", "<leader>s.", show_recent_files, { desc = '[S]earch Recent Files ("." repeat)' })
		map("n", "<leader><leader>", show_buffers, { desc = "[ ] Find existing buffers" })
		map("n", "<leader>td", "<cmd>TodoQuickFix<CR><cmd>copen<CR>", { desc = "[T]odo [D]iagnostics" })
		map("n", "<leader>sm", vim.lsp.buf.document_symbol, { desc = "[S]earch [M]ethods in file" })
		map("n", "<leader>/", find_in_current_buffer, { desc = "[/] Search in current buffer" })
		map("n", "<leader>s/", search_open_buffers, { desc = "[S]earch [/] in Open Files" })
		map("n", "<leader>sn", find_neovim_files, { desc = "[S]earch [N]eovim files" })
	end,
}
