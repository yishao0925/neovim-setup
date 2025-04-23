-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- 禁用 macro 錄製
vim.keymap.set("n", "q", "<Nop>", { noremap = true })

-- Insert 模式中使用 Ctrl + h/j/k/l 來移動光標
vim.keymap.set("i", "<A-h>", "<Left>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-j>", "<Down>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<Up>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-l>", "<Right>", { noremap = true, silent = true })

-- Restore original functionality
keymap.set("n", "H", "H", { noremap = true, silent = true })
keymap.set("n", "L", "L", { noremap = true, silent = true })

-- Delete
local deleteOpts = { noremap = true, silent = true, desc = "Delete without affecting yank" }
keymap.set("n", "<leader>Dd", '"_dd', deleteOpts)
keymap.set("n", "<leader>Daw", '"_daw', deleteOpts)
keymap.set("n", "<leader>Dw", '"_dw', deleteOpts)
keymap.set("n", "<leader>Dw", '"_dw', deleteOpts)
keymap.set("n", "<leader>Diw", '"_diw', deleteOpts)
keymap.set("n", "<leader>Di(", '"_di(', deleteOpts)
keymap.set("n", "<leader>Di{", '"_di{', deleteOpts)
keymap.set("n", "<leader>Di\"", '"_di\"', deleteOpts)
keymap.set("n", "<leader>Di'", '"_di\'', deleteOpts)
keymap.set("x", "<leader>D", '"_d', opts)

-- keymap.set({ "n", "v", "x" }, "p", '""p', { noremap = true, silent = true, desc = "Paste from clipboard" })
keymap.set(
  "x",
  "<leader>P",
  '"_dP',
  { noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)

keymap.set("n", "gsD", function()
  local api = vim.api

  -- 提示用户输入开头符号
  local open_symbol = vim.fn.input("Enter opening symbol: ")
  if open_symbol == "" then
    print("No opening symbol entered.")
    return
  end

  -- 配对的结束符号
  local close_symbol = {
    ["{"] = "}",
    ["["] = "]",
    ["("] = ")",
    ['"'] = '"',
    ["'"] = "'",
    ["<"] = ">",
  }

  -- 获取配对的结束符号
  local close = close_symbol[open_symbol]
  if not close then
    print("Invalid opening symbol.")
    return
  end

  -- 获取光标位置和当前行
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()

  -- 找到要删除的范围
  local start_col, end_col
  -- 从当前位置向左扫描寻找开头符号
  for i = col, 1, -1 do
    if line:sub(i, i) == open_symbol then
      start_col = i
      break
    end
  end

  -- 从当前位置向右扫描寻找结束符号
  for i = col, #line do
    if line:sub(i, i) == close then
      end_col = i
      break
    end
  end

  -- 删除文本
  if start_col and end_col then
    api.nvim_buf_set_text(0, row - 1, start_col - 1, row - 1, end_col, {})
  else
    print("Matching pair not found.")
  end
end, { noremap = true, silent = true })
-- keymap.set({ "n", "v", "x" }, "p", '""p', { noremap = true, silent = true, desc = "Paste from clipboard" })
-- Paste from outside
keymap.set({ "n", "v" }, "<leader>p", '"+p')
keymap.set({ "n", "v" }, "<leader>np", ":put +<CR>")
keymap.set({ "n", "v" }, "<leader>lp", ":put! +<CR>")

-- Increment/Decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "C-x")

-- Delete a word backwards
keymap.set("n", "dw", "vb_d")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

keymap.set("n", "<C-A-k>", "ddkP")
keymap.set("n", "<C-A-j>", "ddp")

-- File path
vim.keymap.set("n", "<leader>pp", function()
  print(vim.fn.expand("%:p"))
end, { noremap = true, silent = true })

local function insertFullPath()
  local filepath = vim.fn.expand("%")
  vim.fn.setreg("+", filepath) -- write to clippoard
end
-- Copy current path
keymap.set("n", "<leader>pc", insertFullPath, { noremap = true, silent = true })

-- Go to definition in new tab
vim.keymap.set("n", "gh", function()
  -- 獲取當前光標位置
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- 創建新 tab，並在新 tab 中複製當前 buffer
  vim.cmd("tab split")

  -- 設置光標到原來的位置
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  -- 在新的 tab 中執行 LSP 定義查找
  vim.lsp.buf.definition()
end, { noremap = true, silent = true })
-- keymap.set("n", "gh", function()
--   local org_path = vim.api.nvim_buf_get_name(0)
--
--   -- Go to definition:
--   -- vim.api.nvim_command("normal gd")
--   vim.cmd("lua vim.lsp.buf.definition()")
--   -- Wait LSP server response
--   vim.wait(200, function() end)
--
--   local new_path = vim.api.nvim_buf_get_name(0)
--   if not (org_path == new_path) then
--     -- Create a new tab for the original file
--     vim.cmd("0tabnew %")
--
--     -- Restore the cursor position
--     vim.api.nvim_command("b " .. org_path)
--     vim.api.nvim_command('normal! `"')
--
--     -- Switch to the original tab
--     vim.api.nvim_command("normal! gt")
--   end
-- end)
vim.keymap.set("n", "<leader>op", ":!open %:p:h<CR>", { noremap = true, silent = true })

-- Diagnostics
keymap.set("n", "<C-k>", function()
  vim.cmd("lua vim.diagnostic.open_float()")
end, opts)
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)

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

-- 定義跳下一個 / 上一個檔案的函式
vim.keymap.set("n", "<leader>bn", function()
  jump_file_by_offset(1)
end, { desc = "下一個檔案" })

vim.keymap.set("n", "<leader>bp", function()
  jump_file_by_offset(-1)
end, { desc = "上一個檔案" })

local function cowboy()
  ---@type table?
  local id
  local ok = true

  for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
    local count = 0
    local timer = assert(vim.loop.new_timer())
    local map = key
    vim.keymap.set("n", key, function()
      if vim.v.count > 0 then
        count = 0
      end
      if count >= 10 then
        ok, id = pcall(vim.notify, "Hold it cowboy!", vim.log.levels.WARN, {
          icon = "😃",
          replace = id,
          keep = function()
            return count >= 10
          end,
        })
        if not ok then
          id = nil
          return map
        end
      else
        count = count + 1
        timer:start(2000, 0, function()
          count = 0
        end)
        return map
      end
    end, { expr = true, silent = true })
  end
end

cowboy()
