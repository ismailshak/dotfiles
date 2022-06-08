local M = {}

--[[
    Language servers installed via npm:

    npm i -g vscode-langservers-extracted
]]

M.setup = function()
	require("lspconfig").eslint.setup({})
	local lspconfig = require("lspconfig")
	local on_attach = function(_, bufnr)
		local opts = { buffer = bufnr }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			vim.inspect(vim.lsp.buf.list_workspace_folders())
		end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		--vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
		vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.formatting, {})
	end

	-- nvim-cmp supports additional completion capabilities
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local present, _ = pcall(require, "cmp_nvim_lsp")
	if present then
		capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
	end

	-- Enable the following language servers
	local servers = { "eslint" }
	for _, lsp in ipairs(servers) do
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end
end

return M
