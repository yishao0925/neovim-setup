local default_flash_config = {
  wrap = false,
  multi_window = false,
  incremental = true,
}

return {
  {
    enabled = true,
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        multi_window = default_flash_config.multi_window,
        wrap = default_flash_config.wrap,
        incremental = default_flash_config.incremental,
      },
      modes = { char = { keys = {} } }
    },
    keys = {
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          local backward_config = vim.tbl_extend("force", default_flash_config, {
            forward = false,
          })
          require("flash").jump({ search = backward_config })
        end,
        desc = "Flash Jump Backward"
      },
      { "<leader>s", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    }
  },

  {
    "telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      -- 關閉預設行為讓 auto-session 使用
      { "<leader>sl", false },
      { "<leader>ss", false },
      { "<leader>sa", false },
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        desc = "Find Plugin File",
      },
      {
        ";f",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r",
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep({
            additional_args = { "--hidden" },
          })
        end,
        desc =
        "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        ";d",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            prompt_title = "Search Folders",
            search_dirs = { "." }, -- 根據需要指定搜索目錄
            hidden = true,         -- 包含隱藏文件夾
            find_command = { "sh", "-c", "find . -type d | grep -v 'node_modules'" },
          })
        end,
        desc = "Search for a directory name in project",
      },
      {
        "\\\\",
        function()
          local builtin = require("telescope.builtin")
          builtin.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          local builtin = require("telescope.builtin")
          builtin.help_tags()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          local builtin = require("telescope.builtin")
          builtin.resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          local builtin = require("telescope.builtin")
          builtin.diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          local builtin = require("telescope.builtin")
          builtin.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        "sf",
        function()
          local telescope = require("telescope")

          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end

          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local fb_actions = require("telescope").extensions.file_browser.actions
      local function open_in_tab(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        if not picker then
          print("無法獲取當前 picker")
          return
        end

        local multi = picker:get_multi_selection()
        actions.close(prompt_bufnr)

        if not vim.tbl_isempty(multi) then
          for _, entry in pairs(multi) do
            if entry.path then
              vim.cmd("tabedit " .. entry.path)
            elseif entry.filename then
              vim.cmd("tabedit " .. entry.filename)
            elseif type(entry.value) == "string" then
              vim.cmd("tabedit " .. entry.value)
            end
          end
        else
          local entry = action_state.get_selected_entry()
          if entry and (entry.path or entry.filename or entry.value) then
            vim.cmd("tabedit " .. (entry.path or entry.filename or entry.value))
          else
            print("光標所指的結果無效")
          end
        end
      end

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = { ["<c-t>"] = open_in_tab },
          i = { ["<c-t>"] = open_in_tab }
        },
      })
      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
        live_grep = {
          mappings = {
            i = {
              ["<C-t>"] = open_in_tab,
              ["<C-u>"] = function(prompt_bufnr)
                local prompt = require("telescope.actions.state").get_current_picker(prompt_bufnr).prompt_bufnr
                vim.api.nvim_buf_set_lines(prompt, 0, -1, false, { "" })
              end,
            },
            n = {
              ["<C-t>"] = open_in_tab,
            },
          },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            -- your custom insert mode mappings
            ["n"] = {
              -- your custom normal mode mappings
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
              ["<C-t>"] = open_in_tab,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },
}
