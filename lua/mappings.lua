require "nvchad.mappings"
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", {desc="Toggle nvim-tree"})

-- Rust debugging mappings - using <leader>b prefix
map("n", "<leader>bb", function() require('dap').toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>br", "<cmd>RustLsp debuggables<cr>", { desc = "Rust debuggables" })
map("n", "<leader>bc", function() require('dap').continue() end, { desc = "Continue" })
map("n", "<leader>bs", function() require('dap').step_over() end, { desc = "Step over" })
map("n", "<leader>bi", function() require('dap').step_into() end, { desc = "Step into" })
map("n", "<leader>bo", function() require('dap').step_out() end, { desc = "Step out" })
map("n", "<leader>bt", function() require('dap').terminate() end, { desc = "Terminate" })
map("n", "<leader>bu", function() require('dapui').toggle() end, { desc = "Toggle DAP UI" })

map("n", "<leader>bd", function()
  -- Build first
  vim.fn.system('cargo build')
  
  -- Get the binary name from Cargo.toml or use default
  local binary_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')  -- Gets folder name
  local program = vim.fn.getcwd() .. '/target/debug/' .. binary_name
  
  -- Ask for arguments
  local args_string = vim.fn.input('Program arguments: ')
  local args = {}
  if args_string ~= "" then
    args = vim.split(args_string, " ")
  end
  
  -- Start debugging
  require('dap').run({
    type = 'codelldb',
    request = 'launch',
    name = 'Debug',
    program = program,
    args = args,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  })
end, { desc = "Build and debug with args" })

-- Git diff mappings - using <leader>g prefix
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open git diff" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "Git file history" })
map("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Close git diff" })
