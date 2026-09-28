-- Generates KEYMAPS.md from the live config, so the reference can never drift
-- from what is actually mapped.
--
--   nvim --headless -u init.lua init.lua -c "luafile scripts/gen-keymaps.lua" -c "qa!"
--
-- Buffer-local maps (LSP, gitsigns) only exist once something has attached, so
-- the script opens a real file in this git repo before dumping.

local MODE_NAMES = {
  n = 'Normal', i = 'Insert', v = 'Visual', x = 'Visual block',
  o = 'Operator-pending', t = 'Terminal', s = 'Select', c = 'Command',
}

-- Groups are matched in order; first hit wins.
local GROUPS = {
  { title = 'Git: blame', match = function(k, d) return d:lower():match('blame') end },
  { title = 'Git: hunks', match = function(k, d) return d:lower():match('git') or d:lower():match('hunk') end },
  { title = 'Search (Telescope)', match = function(k, d) return k:match('^ s') or d:match('Search') end },
  { title = 'LSP', match = function(k, d) return d:match('^LSP:') or d:match('vim%.lsp') end },
  { title = 'Debug (DAP)', match = function(k, d) return d:match('Debug') end },
  -- Anchored on purpose: "Format buffer" and "Find existing buffers" belong
  -- elsewhere, only "Buffer Delete"-style maps belong here.
  { title = 'Buffers & windows', match = function(k, d) return d:match('[Ww]indow') or d:match('^Buffer') end },
  { title = 'Diagnostics', match = function(k, d) return d:lower():match('diagnostic') end },
  { title = 'Surround & text objects', match = function(k, d) return d:match('surrounding') or d:match('textobject') or d:match('node') end },
  { title = 'Toggles', match = function(k, d) return d:match('Toggle') end },
  { title = 'Editing', match = function(k, d) return true end },
}

-- Descriptions use kickstart's [M]nemonic convention, so "[G]it [b]lame" does
-- not contain the literal substring "blame". Strip the brackets before matching.
local function plain(desc)
  return (desc:gsub('%[', ''):gsub('%]', ''))
end

local function pretty(lhs)
  -- Leader is a literal space in the keymap table.
  local s = lhs:gsub('^ ', '<leader>')
  return '`' .. s .. '`'
end

local seen, rows = {}, {}
local function collect(maps, mode, scope)
  for _, k in ipairs(maps) do
    local desc = k.desc or ''
    -- <Plug> maps and the ":help x-default" builtin stubs are noise.
    if desc ~= '' and not k.lhs:match('^<Plug>') and not desc:match('^:help ') then
      local key = mode .. '\0' .. k.lhs
      if not seen[key] then
        seen[key] = true
        table.insert(rows, { mode = mode, lhs = k.lhs, desc = desc, scope = scope })
      end
    end
  end
end

for mode, _ in pairs(MODE_NAMES) do
  collect(vim.api.nvim_buf_get_keymap(0, mode), mode, 'buffer')
  collect(vim.api.nvim_get_keymap(mode), mode, 'global')
end

local out = {}
local function w(line) table.insert(out, line) end

w('# Keymap reference')
w('')
w('Generated from the live config by `scripts/gen-keymaps.lua` — do not edit by hand.')
w('Regenerate with:')
w('')
w('```sh')
w('nvim --headless -u init.lua init.lua -c "luafile scripts/gen-keymaps.lua" -c "qa!"')
w('```')
w('')
w('`<leader>` is <kbd>Space</kbd>. Maps marked *(buf)* are buffer-local and only')
w('appear when something has attached to the buffer (an LSP, gitsigns).')
w('')
w('For a searchable version inside nvim, use `<leader>sk`.')
w('')

for _, group in ipairs(GROUPS) do
  local matched = {}
  for i = #rows, 1, -1 do
    local r = rows[i]
    if group.match(r.lhs, plain(r.desc)) then
      table.insert(matched, r)
      table.remove(rows, i)
    end
  end
  if #matched > 0 then
    table.sort(matched, function(a, b)
      if a.lhs == b.lhs then return a.mode < b.mode end
      return a.lhs < b.lhs
    end)
    w('## ' .. group.title)
    w('')
    w('| Key | Mode | Action |')
    w('|---|---|---|')
    for _, r in ipairs(matched) do
      w(string.format('| %s | %s | %s%s |', pretty(r.lhs), MODE_NAMES[r.mode] or r.mode,
        r.desc:gsub('|', '\\|'), r.scope == 'buffer' and ' *(buf)*' or ''))
    end
    w('')
  end
end

local path = 'KEYMAPS.md'
local f = assert(io.open(path, 'w'))
f:write(table.concat(out, '\n') .. '\n')
f:close()
print('wrote ' .. path .. ' (' .. #out .. ' lines)')
