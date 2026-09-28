-- ============================================================
-- Markdown: in-buffer rendering, glow preview, Telescope picker
--
-- Three complementary ways to read a markdown file:
--   1. render-markdown.nvim - renders the buffer in place (headings,
--      tables, code blocks, checkboxes, callouts). Works with the
--      treesitter `markdown` + `markdown_inline` parsers and with
--      image.nvim for inline images. No browser, no second window.
--   2. `:Glow` - a scrollable, read-only terminal render via the
--      `glow` CLI (`brew install glow`), for a "final document" look.
--   3. `:Telescope markdown` - fuzzy-find markdown files in the cwd
--      with a live preview pane, and act on the highlighted file.
-- ============================================================

local function gh(repo) return 'https://github.com/' .. repo end

-- ------------------------------------------------------------
-- 1. In-buffer rendering
-- ------------------------------------------------------------
vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {
  -- Render in normal/command/terminal mode but not insert, and let
  -- anti_conceal reveal raw syntax on the cursor line, so the source
  -- you are actually editing is never hidden from you.
  render_modes = { 'n', 'c', 't' },
  anti_conceal = { enabled = true },
  heading = { position = 'inline', width = 'block', left_pad = 0, right_pad = 2 },
  code = { style = 'full', width = 'block', right_pad = 2, border = 'thin' },
  checkbox = { unchecked = { icon = '󰄱 ' }, checked = { icon = '󰱒 ' } },
  latex = { enabled = false },
}

vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', { desc = '[T]oggle [M]arkdown rendering' })

-- ------------------------------------------------------------
-- 2. Terminal preview via glow
-- ------------------------------------------------------------

---Open `file` in a floating terminal running glow.
---@param file string
local function glow_preview(file)
  if vim.fn.executable 'glow' ~= 1 then
    vim.notify('glow not found. Install it with: brew install glow', vim.log.levels.ERROR)
    return
  end
  if file == nil or file == '' then
    vim.notify('No file to preview.', vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(120, math.floor(vim.o.columns * 0.9))
  local height = math.floor(vim.o.lines * 0.85)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. vim.fn.fnamemodify(file, ':t') .. ' ',
    title_pos = 'center',
  })

  -- `-p` gives glow its own pager; width is wired to the float so
  -- wrapping matches what we actually drew.
  vim.fn.jobstart({ 'glow', '-p', '-w', tostring(width - 2), file }, { term = true })
  vim.cmd.startinsert()

  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf, desc = 'Close preview' })
end

vim.api.nvim_create_user_command('Glow', function(opts)
  local file = opts.args ~= '' and opts.args or vim.api.nvim_buf_get_name(0)
  glow_preview(file)
end, { nargs = '?', complete = 'file', desc = 'Preview markdown with glow' })

vim.keymap.set('n', '<leader>mp', '<cmd>Glow<CR>', { desc = '[M]arkdown [P]review (glow)' })

-- ------------------------------------------------------------
-- 3. Telescope picker: :Telescope markdown
-- ------------------------------------------------------------
local telescope = require 'telescope'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

---Fuzzy-find markdown files with a preview pane.
---@param opts table|nil standard telescope opts (cwd, hidden, ...)
local function markdown_picker(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.uv.cwd()

  -- rg is used directly (rather than builtin.find_files with a glob) so
  -- the extension works the same whether or not fd is installed.
  local find_command = {
    'rg',
    '--files',
    '--glob=*.md',
    '--glob=*.markdown',
    '--glob=*.mdx',
    '--color=never',
  }
  if opts.hidden then table.insert(find_command, '--hidden') end
  if opts.no_ignore then table.insert(find_command, '--no-ignore') end

  pickers
    .new(opts, {
      prompt_title = 'Markdown Files',
      finder = finders.new_oneshot_job(find_command, { cwd = cwd, entry_maker = require('telescope.make_entry').gen_from_file { cwd = cwd } }),
      sorter = conf.file_sorter(opts),
      previewer = conf.file_previewer(opts),
      attach_mappings = function(prompt_bufnr, map)
        ---Return the absolute path of the highlighted entry.
        local function selected_path()
          local entry = action_state.get_selected_entry()
          if not entry then return nil end
          return vim.fs.normalize(vim.fs.joinpath(cwd, entry.value))
        end

        -- <C-g>: close the picker and hand the file to the glow float.
        map({ 'i', 'n' }, '<C-g>', function()
          local path = selected_path()
          actions.close(prompt_bufnr)
          glow_preview(path)
        end)

        -- <C-y>: copy the path without closing, so several can be grabbed
        -- in a row when writing links between docs.
        map({ 'i', 'n' }, '<C-y>', function()
          local path = selected_path()
          if path then
            vim.fn.setreg('+', vim.fn.fnamemodify(path, ':.'))
            vim.notify('Copied: ' .. vim.fn.fnamemodify(path, ':.'))
          end
        end)

        return true -- keep the default mappings (<CR>, <C-v>, <C-x>, ...)
      end,
    })
    :find()
end

telescope.register_extension {
  exports = { markdown = markdown_picker },
}
pcall(telescope.load_extension, 'markdown')

-- Search markdown files in the cwd
vim.keymap.set('n', '<leader>sm', function() markdown_picker {} end, { desc = '[S]earch [M]arkdown files' })

-- Search markdown files everywhere, including gitignored and hidden ones
vim.keymap.set('n', '<leader>sM', function() markdown_picker { hidden = true, no_ignore = true } end, { desc = '[S]earch [M]arkdown files (all)' })

-- Live grep restricted to markdown files
vim.keymap.set(
  'n',
  '<leader>sG',
  function()
    require('telescope.builtin').live_grep {
      prompt_title = 'Grep Markdown',
      type_filter = 'md',
      additional_args = { '--glob=*.md', '--glob=*.markdown', '--glob=*.mdx' },
    }
  end,
  { desc = '[S]earch [G]rep in markdown' }
)

-- ------------------------------------------------------------
-- 4. Surround Every Line  -  `sel` in visual mode
--
-- mini.surround's visual `sa` wraps the whole selection as one span.
-- This wraps each selected line individually: select 3 lines, press
-- `sel~`, get `~line one~` / `~line two~` / `~line three~`.
-- ------------------------------------------------------------

-- Closing and opening brackets both resolve to the same pair, matching
-- mini.surround's behaviour. Anything else is used on both sides.
local bracket_pairs = {
  ['('] = { '(', ')' },
  [')'] = { '(', ')' },
  ['['] = { '[', ']' },
  [']'] = { '[', ']' },
  ['{'] = { '{', '}' },
  ['}'] = { '{', '}' },
  ['<'] = { '<', '>' },
  ['>'] = { '<', '>' },
}

---Split a line into the part that stays put and the part to be wrapped.
---Indentation and trailing whitespace stay outside the surrounding, so
---`  item` becomes `  ~item~` rather than `~  item~`.
---@param line string
---@return string prefix, string body, string suffix
local function split_line(line)
  local indent, body, trail = line:match '^(%s*)(.-)(%s*)$'

  -- TODO(human): decide whether markdown line prefixes should also stay
  -- outside the surrounding. Right now `- item` becomes `~- item~`, and
  -- `## Heading` becomes `~## Heading~`. Move a matched prefix from the
  -- front of `body` onto `indent` if you would rather get `- ~item~`.
  -- Prefixes worth considering: `- `, `* `, `+ `, `1. `, `> `, `#+ `.

  return indent, body, trail
end

---Wrap each line of the visual selection with a character read from the user.
local function surround_every_line()
  -- `'<` / `'>` are not set until visual mode ends, so read the live anchor
  -- and cursor positions instead.
  local first, last = vim.fn.line 'v', vim.fn.line '.'
  if first > last then
    first, last = last, first
  end

  -- Leave visual mode before editing; 'x' makes it take effect immediately.
  vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)

  vim.api.nvim_echo({ { ('Surround lines %d-%d with: '):format(first, last), 'Question' } }, false, {})
  local char = vim.fn.getcharstr()
  vim.api.nvim_echo({ { '' } }, false, {})

  -- Bail on <Esc> or <C-c>.
  if char == vim.keycode '<Esc>' or char == '\3' or char == '' then return end

  local pair = bracket_pairs[char] or { char, char }
  local left, right = pair[1], pair[2]

  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local changed = 0
  for i, line in ipairs(lines) do
    local indent, body, trail = split_line(line)
    -- Skip blank lines; wrapping them would leave bare `~~` markers behind.
    if body ~= '' then
      lines[i] = indent .. left .. body .. right .. trail
      changed = changed + 1
    end
  end

  -- One call, so the whole thing is a single undo step.
  vim.api.nvim_buf_set_lines(0, first - 1, last, false, lines)
  vim.notify(('Surrounded %d line%s with %s'):format(changed, changed == 1 and '' or 's', left .. right))
end

vim.keymap.set('x', 'sel', surround_every_line, { desc = '[S]urround [E]very [L]ine' })
