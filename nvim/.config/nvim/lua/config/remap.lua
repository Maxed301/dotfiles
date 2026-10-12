local build = require("config.build")

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

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>mb", build.build, { desc = "[M]ake [B]uild" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>mq", "<cmd>copen<CR>", { desc = "[M]ake [Q]uickfix" })

vim.keymap.set(
	"n",
	"<leader>S",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[S]ubstitute word" }
)

local function diagnostic_type(severity)
	return severity == vim.diagnostic.severity.ERROR and "E"
		or severity == vim.diagnostic.severity.WARN and "W"
		or severity == vim.diagnostic.severity.INFO and "I"
		or "H"
end

local function loaded_diagnostics_to_items(severity)
	local diagnostics = vim.diagnostic.get(nil, severity and { severity = severity } or nil)
	local items = {}

	for _, diagnostic in ipairs(diagnostics) do
		local filename = vim.api.nvim_buf_get_name(diagnostic.bufnr)
		table.insert(items, {
			filename = filename ~= "" and filename or nil,
			bufnr = filename == "" and diagnostic.bufnr or nil,
			lnum = diagnostic.lnum + 1,
			col = diagnostic.col + 1,
			text = diagnostic.message,
			type = diagnostic_type(diagnostic.severity),
		})
	end

	return items
end

local function workspace_report_to_items(report, severity)
	local items = {}
	local reports = report and report.items or {}

	for _, file_report in ipairs(reports) do
		local uri = file_report.uri
		local filename = uri and vim.uri_to_fname(uri) or nil
		for _, diagnostic in ipairs(file_report.items or {}) do
			if not severity or diagnostic.severity == severity then
				local start = diagnostic.range and diagnostic.range.start or { line = 0, character = 0 }
				table.insert(items, {
					filename = filename,
					lnum = start.line + 1,
					col = start.character + 1,
					text = diagnostic.message,
					type = diagnostic_type(diagnostic.severity),
				})
			end
		end
	end

	return items
end

local function set_diagnostics_quickfix(items, severity, source)
	vim.fn.setqflist({}, "r", {
		title = severity == vim.diagnostic.severity.ERROR and "LSP errors" or "LSP diagnostics",
		items = items,
	})

	if #items > 0 then
		vim.cmd("copen")
	else
		vim.cmd("cclose")
		vim.notify("No diagnostics" .. (source and (" (" .. source .. ")") or ""), vim.log.levels.INFO)
	end
end

local function diagnostics_to_quickfix(severity)
	local loaded_items = loaded_diagnostics_to_items(severity)
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local workspace_clients = {}
	local method = vim.lsp.protocol.Methods.workspace_diagnostic or "workspace/diagnostic"

	for _, client in ipairs(clients) do
		if client.supports_method and client:supports_method(method) then
			table.insert(workspace_clients, client)
		end
	end

	if #workspace_clients == 0 then
		set_diagnostics_quickfix(loaded_items, severity, "loaded buffers only; server has no workspace diagnostics")
		return
	end

	local pending = #workspace_clients
	local workspace_items = {}

	for _, client in ipairs(workspace_clients) do
		client:request(method, { previousResultIds = {} }, function(err, result)
			if not err then
				vim.list_extend(workspace_items, workspace_report_to_items(result, severity))
			end

			pending = pending - 1
			if pending == 0 then
				if #workspace_items > 0 then
					set_diagnostics_quickfix(workspace_items, severity, "workspace")
				else
					set_diagnostics_quickfix(loaded_items, severity, "loaded buffers fallback")
				end
			end
		end, 0)
	end
end

vim.api.nvim_create_user_command("Diagnostics", function()
	diagnostics_to_quickfix()
end, { desc = "Show all LSP diagnostics in quickfix" })

vim.api.nvim_create_user_command("LspErrors", function()
	diagnostics_to_quickfix(vim.diagnostic.severity.ERROR)
end, { desc = "Show LSP errors in quickfix" })

vim.keymap.set("n", "<leader>sd", "<cmd>Diagnostics<CR>", { desc = "[S]earch [D]iagnostics", silent = true })
vim.keymap.set("n", "<leader>le", "<cmd>LspErrors<CR>", { desc = "Show [L]SP [E]rrors", silent = true })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "]g", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end)

vim.keymap.set("n", "[g", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end)

vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("so")
end, { desc = "[R]eload config" })

local function restart_lsp()
	local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
	for _, client in ipairs(get_clients()) do
		if client.stop then
			client:stop()
		else
			vim.lsp.stop_client(client.id)
		end
	end
	vim.defer_fn(function()
		vim.cmd("edit")
	end, 100)
end

vim.api.nvim_create_user_command("LspRestart", restart_lsp, { desc = "Restart LSP clients" })
vim.keymap.set("n", "<leader>lr", restart_lsp, { desc = "[L]SP [R]estart", silent = true })

local diagnostics_active = true
local virtual_text_active = true

local function apply_diagnostics_state()
	vim.diagnostic.config({
		virtual_text = diagnostics_active and virtual_text_active,
		signs = diagnostics_active,
		underline = diagnostics_active,
		update_in_insert = false,
		severity_sort = true,
	})
end

vim.keymap.set("n", "<leader>ii", function()
	virtual_text_active = not virtual_text_active
	apply_diagnostics_state()
end, { desc = "Toggle diagnostics virtual text", silent = true })

vim.keymap.set("n", "<leader>id", function()
	diagnostics_active = not diagnostics_active
	apply_diagnostics_state()
end, { desc = "Toggle diagnostics", silent = true })
