-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- ╭────────────────────────────────────────────────────╮
-- │ 基本操作：禁用、移動、選取                           │
-- ╰────────────────────────────────────────────────────╯

-- 禁用 macro 錄製
keymap.set("n", "q", "<Nop>", opts)

-- Insert 模式中 Alt+h/j/k/l 移動光標
keymap.set("i", "<A-h>", "<Left>", opts)
keymap.set("i", "<A-j>", "<Down>", opts)
keymap.set("i", "<A-k>", "<Up>", opts)
keymap.set("i", "<A-l>", "<Right>", opts)

-- 恢復原始 H/L 功能
keymap.set("n", "H", "H", opts)
keymap.set("n", "L", "L", opts)

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G", opts)

-- Delete a word backwards
keymap.set("n", "dw", "vb_d", opts)

-- Increment/Decrement
keymap.set("n", "+", "<C-a>", opts)
keymap.set("n", "-", "C-x", opts)

-- Disable continuations when creating new lines
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- ╭────────────────────────────────────────────────────╮
-- │ 窗口操作（分割 / 移動 / 縮放）                       │
-- ╰────────────────────────────────────────────────────╯

-- Split window
keymap.set("n", "ss", ":split<CR>", opts)
keymap.set("n", "sv", ":vsplit<CR>", opts)

-- Move between windows
keymap.set("n", "sh", "<C-w>h", opts)
keymap.set("n", "sk", "<C-w>k", opts)
keymap.set("n", "sj", "<C-w>j", opts)
keymap.set("n", "sl", "<C-w>l", opts)

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><", opts)
keymap.set("n", "<C-w><right>", "<C-w>>", opts)
keymap.set("n", "<C-w><up>", "<C-w>+", opts)
keymap.set("n", "<C-w><down>", "<C-w>-", opts)

-- ╭────────────────────────────────────────────────────╮
-- │ 特殊功能：成對刪除符號                             │
-- ╰────────────────────────────────────────────────────╯

keymap.set("n", "gsD", function()
  local api = vim.api
  local open_symbol = vim.fn.input("Enter opening symbol: ")
  if open_symbol == "" then
    print("No opening symbol entered.")
    return
  end
  local close_symbol = { ["{"] = "}", ["["] = "]", ["("] = ")", ['"'] = '"', ["'"] = "'", ["<"] = ">" }
  local close = close_symbol[open_symbol]
  if not close then
    print("Invalid opening symbol.")
    return
  end
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local start_col, end_col
  for i = col, 1, -1 do
    if line:sub(i, i) == open_symbol then
      start_col = i
      break
    end
  end
  for i = col, #line do
    if line:sub(i, i) == close then
      end_col = i
      break
    end
  end
  if start_col and end_col then
    api.nvim_buf_set_text(0, row - 1, start_col - 1, row - 1, end_col, {})
  else
    print("Matching pair not found.")
  end
end, opts)

-- ╭────────────────────────────────────────────────────╮
-- │ Cowboy Mode（防止連續移動過快提醒）                  │
-- ╰────────────────────────────────────────────────────╯

local function cowboy()
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

-- ╭────────────────────────────────────────────────────╮
-- │ 特別補充：視覺模式刪除不影響 yank                  │
-- ╰────────────────────────────────────────────────────╯

keymap.set("x", "<leader>D", '"_d', { desc = "Delete selection (no yank)", silent = true, noremap = true })
