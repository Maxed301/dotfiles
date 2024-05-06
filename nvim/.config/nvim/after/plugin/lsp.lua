vim.cmd([[autocmd! ColorScheme * highlight Float ctermbg=NONE guibg=NONE]])
vim.cmd([[autocmd! ColorScheme * highlight FloatBorder ctermbg=NONE guibg=NONE]])
local magenta = "#bb9af7"
vim.api.nvim_set_hl(0, "FloatBorder", { fg = magenta, bg = "none" })

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
