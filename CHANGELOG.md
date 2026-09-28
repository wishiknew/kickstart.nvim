# Changelog

Notable changes to this config, newest last. Moved out of `init.lua`
(where it lived as a comment block) so the config file stays config and
the reasoning has room to breathe.

Each entry records *why*, not just what — the rationale is the part that is
expensive to reconstruct later. See `COOKBOOK.md` for task-oriented recipes
and `KEYMAPS.md` for the generated key reference.

## 2026-08-27

Autosave writes now use `noautocmd` so the per-second background write no longer triggers BufWrite autocmds (conform's format_on_save, fidget notifications, etc). Manual :w still runs autocmds and shows notifications as normal.

## 2026-08-28

Added image/SVG preview support: `image.nvim` (Section 4) for inline rendering in buffers, markdown, and the nvim-tree file tree (backend = 'kitty'; requires a graphics-capable terminal, and `librsvg` for SVG rasterization); `telescope-media-files.nvim` (Section 5) for preview-on-select in a dedicated `<leader>fm` picker (requires `chafa`, and `rg`/`fd` for its find_cmd).

## 2026-09-01

Markdown preview + fixed the 2026-08-28 image support, which never actually rendered. Corrections to that entry: `image.nvim`'s processor (`magick_cli`) needs ImageMagick, which was missing; `backend` is no longer hardcoded to 'kitty' but detected from TERM_PROGRAM / KITTY_WINDOW_ID, resolving to 'sixel' on iTerm2 (which does NOT speak the Kitty protocol) and 'kitty' on Ghostty/WezTerm/Kitty - override with $IMAGE_NVIM_BACKEND; and `integrations.nvim_tree` does not exist in current image.nvim (no such file under lua/image/integrations/) so it was silently ignored - removed. Viewing an image from the tree works via `hijack_file_patterns` instead: `<CR>` on an image renders it in a buffer. Sizing: dropped `max_width`/`max_height`, which are absolute caps in columns/rows applied AFTER the percentage caps, so `max_height = 12` overrode them and shrank every image; now 100% window width / 80% height. `max_width_window_percentage = math.huge` passed the plugin's `type(x) == 'number'` guard and computed math.floor(inf) - now 100. Added `<leader>ti` / `:ImageToggle` to toggle inline images, since images are drawn over the window and cannot reflow around text. Also: `require 'custom.plugins'` was commented out, so the whole lua/custom/plugins/ directory was dead code - enabled. New lua/custom/plugins/markdown.lua adds `render-markdown.nvim` (in-buffer rendering, `<leader>tm`), a glow-based float (`:Glow`, `<leader>mp`, needs `brew install glow`), and a `:Telescope markdown` picker (`<leader>sm`, `<leader>sM` for hidden/ignored, `<leader>sG` to grep markdown only, `<C-g>` in-picker to open the highlighted file in glow). Installed `poppler` so telescope-media-files' `pdf` filetype - listed since 2026-08-28 but needing `pdftoppm` - actually previews. Also adds `sel` in Visual mode ([S]urround [E]very [L]ine): wraps each selected line individually with a character read after the mapping, which mini.surround's visual `sa` cannot do (it treats the selection as one span). Indentation and trailing whitespace stay outside the markers, blank lines are skipped, and the whole range is one undo step. Note the range is read via line('v')/line('.') because '< and '> are not set until visual mode ends.

## 2026-09-23

Notes on using a Redis connection in `vim.g.dbs` alongside a Postgres one, reachable from `<leader>Do`. No plugin needed - vim-dadbod already ships a redis adapter (autoload/db/adapter/redis.vim). Worth knowing before reaching for it: that adapter is a thin shell-out to `redis-cli`, translating the URL into `-h -p --user -a -n` flags (and `--tls` for `rediss://`). So the query buffer takes raw Redis commands (`SCAN`, `HGETALL`, `TTL`), not SQL, and dadbod-ui's schema tree stays empty - there are no tables to expand, just a connection and a scratch buffer. The `/0` path maps to `-n 0`, selecting the DB index. Prefer `SCAN` over `KEYS`: irrelevant locally, but `KEYS` blocks the server and the reflex carries. On passwords: omit one if the server is unauthenticated. Passing `-a` to a server with no password makes redis-cli print `AUTH failed: ERR AUTH <password> called without any password configured` before every result - commands still run, but the noise also feeds dadbod's auth-failure sniffing. A containerised Redis (docker-compose) usually has different auth than a local brew instance on the same port; make sure you know which one is actually serving 6379. With a password: `redis://:pw@host:6379/0`. Connection URLs themselves now live in the gitignored lua/custom/local.lua.

## 2026-09-28

**Git blame, in three levels of detail** (see COOKBOOK ch. 6.2):

- `<leader>tb` — inline ghost text via `current_line_blame`, on at startup, follows the cursor
- `<leader>gb` — per-line popup with the commit message and the diff that introduced it
- `<leader>gB` — scroll-bound full-file blame split

Three settings make always-on blame liveable rather than noise: `delay = 300`
(the 1000ms default feels laggy when scanning), `ignore_whitespace` (without it
one reformat commit claims every line in the file — this is the important one),
and `use_focus` (blame renders only in the focused window).

Wired the rest of the gitsigns set directly into `on_attach` — stage/reset
including visual, buffer-wide stage/reset, diff against index or HEAD, hunks to
quickfix, and `ih` as a hunk text object. Deliberately *not* done by
uncommenting `lua/kickstart/plugins/gitsigns.lua`: that file calls `setup()` a
second time and would clobber the custom `signs` table. Replaced the deprecated
`next_hunk`/`prev_hunk` with `nav_hunk`.

Also added window resize on `<C-arrows>`, `<leader>bd` / `<leader>bo` for
buffers, and editing quality-of-life: indent keeps the selection, visual `J`/`K`
move lines, `<leader>p` pastes without clobbering the register, `n`/`N` centre
the view.

Docs: `KEYMAPS.md` is a full reference generated from the *live* config by
`scripts/gen-keymaps.lua`, so it cannot drift from what is actually mapped.

## 2026-09-28 (b)

`<leader>sk` now passes explicit `modes` to Telescope's keymaps picker.

The default is `{ n, i, c, x }`, which silently hides two whole categories:
operator-pending maps (the `ih` git-hunk text object, mini.ai's `ia`/`aa`) and
terminal maps (`<Esc><Esc>`). Visual maps such as the new `J`/`K` line moves
*did* already show, because a map created with mode `v` is also reported for
`x` — so the picker was never as complete as it looked, though not in the way
you would guess.

Now asks for `{ n, i, c, x, v, o, t, s }` and sets `show_plug = false`, which
drops 48 `<Plug>` entries that are plumbing rather than keys anyone presses.
Net: 294 real entries.

Caveat worth remembering: the picker reads buffer-local maps from the *current*
buffer, so LSP and gitsigns maps only appear when you open it from a buffer
those have attached to. Opening `<leader>sk` from a scratch buffer will never
list the blame maps.

## 2026-09-28 (c)

Moved this changelog out of `init.lua` into `CHANGELOG.md`. It had grown to
~100 lines of comment at the bottom of the config file, which is prose, not
configuration — `init.lua` is 1427 lines and this reclaims about 93 of them.
`init.lua` keeps a three-line pointer so the trail is not lost.
