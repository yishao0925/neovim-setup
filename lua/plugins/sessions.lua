return {
  "echasnovski/mini.sessions",
  version = false,
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  config = function()
    local sessions = require("mini.sessions")

    sessions.setup({
      -- 儲存 session 的資料夾
      directory = vim.fn.stdpath("data") .. "/sessions",
      autowrite = true,     -- 自動寫入當前 session
      file = "session.vim", -- 預設 session 檔名
    })

    -- 自動儲存/讀取最近 session（可選）
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        sessions.write("last-session")
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local path = sessions.config.directory .. "/last-session.vim"
        if vim.fn.filereadable(path) == 1 then
          sessions.read("last-session")
        end
      end,
    })

    -- 快捷鍵綁定
    vim.keymap.set("n", "<leader>sl", function()
      sessions.select()
    end, { desc = "載入 session（Telescope）" })

    vim.keymap.set("n", "<leader>ss", function()
      vim.ui.input({ prompt = "儲存 session 名稱：" }, function(input)
        if input then
          sessions.write(input)
        end
      end)
    end, { desc = "儲存 session" })

    vim.keymap.set("n", "<leader>sd", function()
      vim.ui.input({ prompt = "刪除 session 名稱：" }, function(input)
        if input then
          sessions.delete(input)
        end
      end)
    end, { desc = "刪除 session" })
  end,
}
