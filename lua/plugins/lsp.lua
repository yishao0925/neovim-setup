return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }, -- 需要的依赖
    config = function()
      local null_ls = require("null-ls")

      -- 设置 `null-ls` 并添加 Prettier 作为格式化工具
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            condition = function(utils)
              return utils.root_has_file({
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.js",
                "prettier.config.js",
                ".prettierrc.yaml",
                ".prettierrc.yml",
              }) or vim.fn.executable("prettier") == 1
            end,
          }),
        },
      })
    end,
  },
  -- tools
  {
    "williamboman/mason.nvim",
    config = function()
      local mason = require("mason")
      mason.setup({
        ensure_installed = {
          "stylua",
          "selene",
          "luacheck",
          "shellcheck",
          "shfmt",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "tsserver",
          "cssls",
          "emmet_language_server",
          "html",
          "eslint",
          "yamlls",
          "lua_ls",
        },
      })

      local lspconfig = require("lspconfig")

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          if server_name == "vtsls" then
            return
          end
          lspconfig[server_name].setup({})
        end,
      })
    end,
  },
  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      ---@type lspconfig.options
      servers = {
        vtsls = { enabled = false },
        tsserver = {
          on_attach = function(client)
            -- 禁用 tsserver 内置的格式化功能
            client.server_capabilities.documentFormattingProvider = false
            vim.cmd("autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting()")
          end,
          root_dir = function(...)
            return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        eslint = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern("package.json", ".eslintrc", ".eslintrc.js", ".git")(...)
          end,
        },
        emmet_language_server = {
          filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "pug",
            "typescriptreact",
          },
        },
        cssls = {},
        tailwindcss = { enabled = false },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      vim.list_extend(keys, {
        {
          "gd",
          function()
            -- DO NOT RESUSE WINDOW
            require("telescope.builtin").lsp_definitions({ reuse_win = false })
          end,
          desc = "Goto Definition",
          has = "definition",
        },
      })
    end,
  },
}
