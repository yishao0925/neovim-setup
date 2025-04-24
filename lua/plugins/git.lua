return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
    },
    event = "BufRead",
    config = function()
      -- 將輸入的 `:git` 自動展開為 `:Git`
      vim.cmd([[
        cnoreabbrev <expr> git getcmdtype() == ':' && getcmdline() == 'git' ? 'Git' : 'git'
      ]])

      local git_aliases = {
        ga = "add",
        gaa = "add --all",
        gapa = "add --patch",
        gau = "add --update",
        gav = "add --verbose",
        gwip = "add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message ",
        gam = "am",
        gama = "am --abort",
        gamc = "am --continue",
        gamscp = "am --show-current-patch",
        gams = "am --skip",
        gap = "apply",
        gapt = "apply --3way",
        gbs = "bisect",
        gbsb = "bisect bad",
        gbsg = "bisect good",
        gbsn = "bisect new",
        gbso = "bisect old",
        gbsr = "bisect reset",
        gbss = "bisect start",
        gbl = "blame -w",
        gb = "branch",
        gba = "branch --all",
        gbd = "branch --delete",
        gbD = "branch --delete --force",
        gbm = "branch --move",
        gbnm = "branch --no-merged",
        gbr = "branch --remote",
        ggsup = "branch --set-upstream-to=origin/$(git_current_branch)",
        gco = "checkout",
        gcor = "checkout --recurse-submodules",
        gcb = "checkout -b",
        gcB = "checkout -B",
        gcd = "checkout $(git_develop_branch)",
        gcm = "checkout $(git_main_branch)",
        gcp = "cherry-pick",
        gcpa = "cherry-pick --abort",
        gcpc = "cherry-pick --continue",
        gclean = "clean --interactive -d",
        gcl = "clone --recurse-submodules",
        gclf = "clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules",
        gcam = "commit --all --message",
        gcas = "commit --all --signoff",
        gcasm = "commit --all --signoff --message",
        gcs = "commit --gpg-sign",
        gcss = "commit --gpg-sign --signoff",
        gcssm = "commit --gpg-sign --signoff --message",
        gcmsg = "commit --message",
        gcsm = "commit --signoff --message",
        gc = "commit --verbose",
        gca = "commit --verbose --all",
        gcn = "commit --verbose --no-edit",
        gcf = "config --list",
        gd = "diff",
        gdca = "diff --cached",
        gds = "diff --staged",
        glg = "log --stat",
        glgp = "log --stat --patch",
        gignored = "ls-files -v | grep ",
        gm = "merge",
        gma = "merge --abort",
        gmc = "merge --continue",
        gmom = "merge origin/$(git_main_branch)",
        gl = "pull",
        gpr = "pull --rebase",
        gp = "push",
        gpf = "push --force-with-lease",
        gpoat = "push origin --all && git push origin --tags",
        grev = "revert",
        grm = "rm",
        grmc = "rm --cached",
        gsh = "show",
        gst = "status",
        gss = "status --short",
        gsb = "status --short --branch",
        gsw = "switch",
        gswc = "switch --create",
        gta = "tag --annotate",
        gts = "tag --sign",
        gtv = "tag | sort -V",
      }

      -- 建立合法命令（G開頭）註冊 :Gco, :Gcam 等
      for alias, cmd in pairs(git_aliases) do
        local command_name = alias:gsub("^%l", string.upper) -- gco -> Gco

        vim.api.nvim_create_user_command(command_name, function(opts)
          local args = table.concat(opts.fargs, " ")
          vim.cmd("Git " .. cmd .. " " .. args)
        end, {
          nargs = "*",
          desc = "Git alias for :Git " .. cmd,
        })
      end

      -- 自動建立 cnoreabbrev 映射：輸入 gco → Gco
      for alias, _ in pairs(git_aliases) do
        local command_name = alias:gsub("^%l", string.upper)
        vim.cmd(
          string.format(
            "cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdline() == '%s' ? '%s' : '%s'",
            alias,
            alias,
            command_name,
            alias
          )
        )
      end
    end,
  },
  {

    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end)

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end)

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk)
          map("n", "<leader>hr", gitsigns.reset_hunk)
          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("n", "<leader>hS", gitsigns.stage_buffer)
          map("n", "<leader>hu", gitsigns.undo_stage_hunk)
          map("n", "<leader>hR", gitsigns.reset_buffer)
          map("n", "<leader>hp", gitsigns.preview_hunk)
          map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
          end)
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
          map("n", "<leader>hd", gitsigns.diffthis)
          map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
          end)
          map("n", "<leader>td", gitsigns.toggle_deleted)

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },
  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    },
  },
}
