-- lua/configs/jdtls.lua

local home = os.getenv "HOME"
local jdtls = require "jdtls"

-- Find the root of the project (looks for these markers going up)
local root_dir = jdtls.setup.find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

-- Unique workspace dir per project (avoids conflicts between projects)
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

-- Path to jdtls installed by Mason
local mason_path = home .. "/.local/share/nvim/mason"
local jdtls_path = mason_path .. "/packages/jdtls"
local jdtls_bin = mason_path .. "/bin/jdtls"

-- Path to java-debug and vscode-java-test (optional, for debugging)
local bundles = {}

-- Try to add java-debug bundle if installed via Mason
local java_debug_path = mason_path .. "/packages/java-debug-adapter"
if vim.fn.isdirectory(java_debug_path) == 1 then
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))
end

-- Try to add vscode-java-test bundle if installed via Mason
local java_test_path = mason_path .. "/packages/java-test"
if vim.fn.isdirectory(java_test_path) == 1 then
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"))
end

local config = {
  cmd = { jdtls_bin },

  root_dir = root_dir,

  settings = {
    java = {
      home = "/usr/lib/jvm/jdk-25", -- adjust if different
      eclipse = { downloadSources = true },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-25",
            path = "/usr/lib/jvm/jdk-25",
          },
        },
      },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      inlayHints = { parameterNames = { enabled = "all" } },
      format = { enabled = true },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.junit.Assert.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
    },
    contentProvider = { preferred = "fernflower" },
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  flags = { allow_incremental_sync = true },

  init_options = {
    bundles = bundles,
  },

  -- Keymaps that only activate in Java files
  on_attach = function(client, bufnr)
    -- Enable jdtls-specific extras (code actions, organize imports, etc.)
    jdtls.setup_dap { hotcodereplace = "auto" }
    jdtls.setup.add_commands()

    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract Method" }))
    vim.keymap.set("n", "<leader>jt", jdtls.test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test Nearest Method" }))
    vim.keymap.set("n", "<leader>jT", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Test Class" }))
  end,

  capabilities = require("nvchad.configs.lspconfig").capabilities,
}

return config
