-- 切換 file
local function jump_file_by_offset(offset)
  local current_file = vim.fn.expand("%:t")
  local current_dir = vim.fn.expand("%:p:h") .. "/"

  -- 取得目前資料夾的所有檔案（不含資料夾）
  local files = vim.fn.readdir(current_dir, function(name)
    return vim.fn.isdirectory(current_dir .. name) == 0
  end)

  table.sort(files)

  local current_index = nil
  for i, file in ipairs(files) do
    if file == current_file then
      current_index = i
      break
    end
  end

  if not current_index then
    print("⚠ 無法在當前目錄找到目前的檔案")
    return
  end

  -- 計算新的 index，並支援循環
  local next_index = ((current_index - 1 + offset) % #files) + 1
  local next_file = current_dir .. files[next_index]

  vim.cmd("edit " .. vim.fn.fnameescape(next_file))
end

-- plugins/which-key.lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    spec = {
      ["<leader>D"] = { name = "+delete (no yank)" },
      ["<leader>p"] = { name = "+path" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>w"] = { name = "+window" },
      ["<leader>l"] = { name = "+line" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
    -- ╭─ Delete 群組 ─╮
    { "<leader>Dd",  '"_dd',     desc = "Delete line",          mode = "n" },
    { "<leader>Daw", '"_daw',    desc = "Delete a word",        mode = "n" },
    { "<leader>Dw",  '"_dw',     desc = "Delete word (right)",  mode = "n" },
    { "<leader>Diw", '"_diw',    desc = "Delete inner word",    mode = "n" },
    { "<leader>Di(", '"_di(',    desc = "Delete inside ()",     mode = "n" },
    { "<leader>Di{", '"_di{',    desc = "Delete inside {}",     mode = "n" },
    { '<leader>Di"', '"_di\\"',  desc = 'Delete inside "',      mode = "n" },
    { "<leader>Di'", "'_di\\''", desc = "Delete inside '",      mode = "n" },

    -- ╭─ Path / File 群組 ─╮
    { "<leader>pf",  '"+p',      desc = "Paste from clipboard", mode = { "n", "v" } },
    {
      "<leader>pp",
      function()
        print(vim.fn.expand("%:p"))
      end,
      desc = "Print full path",
      mode = "n",
    },
    {
      "<leader>pc",
      function()
        vim.fn.setreg("+", vim.fn.expand("%"))
      end,
      desc = "Copy file path",
      mode = "n",
    },
    { "<leader>np", ":put +<CR>",       desc = "Paste below",      mode = { "n", "v" } },
    { "<leader>lp", ":put! +<CR>",      desc = "Paste above",      mode = { "n", "v" } },
    { "<leader>op", ":!open %:p:h<CR>", desc = "Open file folder", mode = "n" },

    -- ╭─ File switch 群組 ─╮
    {
      "<leader>bn",
      function()
        jump_file_by_offset(1)
      end,
      desc = "下一個檔案",
      mode = "n",
    },
    {
      "<leader>bl",
      function()
        jump_file_by_offset(-1)
      end,
      desc = "上一個檔案",
      mode = "n",
    },

    -- ╭─ Window 群組 ─╮
    { "<leader>ws", ":split<CR>",   desc = "Horizontal Split",     mode = "n" },
    { "<leader>wv", ":vsplit<CR>",  desc = "Vertical Split",       mode = "n" },
    { "<leader>wh", "<C-w>h",       desc = "Move to left window",  mode = "n" },
    { "<leader>wj", "<C-w>j",       desc = "Move to below window", mode = "n" },
    { "<leader>wk", "<C-w>k",       desc = "Move to upper window", mode = "n" },
    { "<leader>wl", "<C-w>l",       desc = "Move to right window", mode = "n" },
    { "<leader>w<", "<C-w><",       desc = "Decrease width",       mode = "n" },
    { "<leader>w>", "<C-w>>",       desc = "Increase width",       mode = "n" },
    { "<leader>w+", "<C-w>+",       desc = "Increase height",      mode = "n" },
    { "<leader>w-", "<C-w>-",       desc = "Decrease height",      mode = "n" },

    -- ╭─ 行操作（Line）群組 ─╮
    { "<leader>lk", "ddkP",         desc = "Swap line up",         mode = "n" },
    { "<leader>lj", "ddp",          desc = "Swap line down",       mode = "n" },

    -- ╭─ Tab、跳轉、LSP 等 ─╮
    { "<C-m>",      "<C-i>",        desc = "Jump forward",         mode = "n" },
    { "te",         ":tabedit",     desc = "New tab",              mode = "n" },
    { "<tab>",      ":tabnext<CR>", desc = "Next tab",             mode = "n" },
    { "<s-tab>",    ":tabprev<CR>", desc = "Prev tab",             mode = "n" },
    {
      "gh",
      function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd("tab split")
        vim.api.nvim_win_set_cursor(0, pos)
        vim.lsp.buf.definition()
      end,
      desc = "Definition in new tab",
      mode = "n",
    },
    {
      "<C-k>",
      function()
        vim.diagnostic.open_float()
      end,
      desc = "Diagnostics (float)",
      mode = "n",
    },
    {
      "<C-j>",
      function()
        vim.diagnostic.goto_next()
      end,
      desc = "Next diagnostic",
      mode = "n",
    },
  },
}
