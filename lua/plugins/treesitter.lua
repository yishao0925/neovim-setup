return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "astro",
        "cmake",
        "cpp",
        "css",
        "fish",
        "gitignore",
        "go",
        "graphql",
        "http",
        "java",
        "php",
        "rust",
        "scss",
        "sql",
        "svelte",
      },

      -- matchup = {
      -- 	enable = true,
      -- },

      -- https://github.com/nvim-treesitter/playground#query-linter
      query_linter = {
        enable = false, -- 調試用，平常關閉以提升效能
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "+",
          node_incremental = "+",
          scope_incremental = false,
          node_decremental = "-",
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["aj"] = "@jsx_element.outer",
            ["ij"] = "@jsx_element.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- 記錄到 jumplist，讓你可以用 <C-o> 返回
          goto_next_start = {
            ["]j"] = "@jsx_element.outer",
          },
          goto_previous_start = {
            ["[j"] = "@jsx_element.outer",
          },
        },
      },

      playground = {
        enable = false, -- 調試用，需要時再開啟
        disable = {},
        updatetime = 25,
        persist_queries = true,
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
