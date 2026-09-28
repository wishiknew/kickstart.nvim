# The Neovim Cookbook

My working notes for this config. Not a tutorial and not an install guide — that's
[`README.md`](README.md), which is still upstream kickstart's. This is the book I open
when I know *what* I want to do and have forgotten *how*.

Everything here is either bound in this repo or something I've actually typed. Recipes
cite where a mapping is defined (`init.lua:641`) so this file and the code can't quietly
drift apart.

**Three kinds of entry:**

| Kind | Looks like | For |
|---|---|---|
| **Recipe** | Problem / Solution / Discussion | "I want to do X" |
| **Q&A** | **Q:** … **A:** … | A single fact I keep re-looking-up |
| **Technique** | Prose + keystrokes | A skill, not a one-off task |

Cross-references are by number: *see 3.2*.

---

> **Looking for a specific key?** `KEYMAPS.md` is a complete, generated
> reference of every mapping in this config. Inside nvim, `<leader>sk` searches
> them live. This cookbook covers the *why*; that file covers the *what*.
>
> **Wondering when something changed, and why?** `CHANGELOG.md` records each
> change to this config along with the reasoning behind it.

## Setup at a glance

| | |
|---|---|
| **Base** | A personal fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — single-file `init.lua`, ~1200 lines, ten numbered sections |
| **Neovim** | v0.12.4 |
| **Plugin manager** | Built-in `vim.pack` (**not** lazy.nvim). Lockfile: `nvim-pack-lock.json`, 29 plugins |
| **Leader** | `<Space>` — and localleader is also `<Space>` (`init.lua:98`) |
| **Colorscheme** | `industry`, a *built-in* scheme (`init.lua:429`) — see D.2 |
| **Completion** | blink.cmp + LuaSnip (not nvim-cmp) |
| **Finder** | telescope + fzf-native |
| **Tree** | nvim-tree on `<leader>e` (not neo-tree) |
| **Statusline** | mini.statusline |
| **Autosave** | On — every second, silently. See 10.6 |
| **Format on save** | Python only (ruff). Everything else is manual `<leader>f` |
| **Clipboard** | `unnamedplus` — plain `y` already goes to the system clipboard |

My additions on top of stock kickstart: nvim-tree, image.nvim, telescope-media-files,
a Python DAP section, an autosave/autoread pair of timers, and the whole
`lua/custom/plugins/markdown.lua` stack.

---

# 1. Getting around

## 1.1 Recipe: Jump to a buffer I already have open

**Problem.** Several files open, and `:e path/to/thing` means retyping a path.

**Solution.**

```vim
<leader><leader>          " telescope buffer picker — the one I actually use
:buffers                  " numbered list
:b 2                      " jump to buffer 2
:b partial-name           " jump by substring
```

**Discussion.** `<leader><leader>` (`init.lua:644`) beats `:buffers` + `:b N` because it
fuzzy-matches and previews. `:b <partial>` is still worth knowing for when the picker
isn't up: it matches any substring of the path, and `<Tab>` completes.

## 1.2 Recipe: Close a buffer that refuses to close

**Problem.** `:bd` errors with "No write since last change".

**Solution.**

```vim
:bd          " close current buffer
:bd!         " close it, discarding changes
:bd 5        " close buffer 5 by number
```

**Discussion.** `vim.o.confirm = true` (`init.lua:173`) means most quit-ish commands
prompt instead of erroring outright, so `:q` on a dirty buffer asks rather than refuses.
`:bd!` skips the question. Note that with autosave running (10.6) an unwritten buffer is
rare — if `:bd` complains, the buffer is usually one autosave skips: no filename, or a
special `buftype` like a terminal.

## 1.3 Technique: Windows

```vim
:sp        " horizontal split
:vs        " vertical split
<C-h>      " focus left        (init.lua:235)
<C-l>      " focus right       (init.lua:236)
<C-j>      " focus down        (init.lua:237)
<C-k>      " focus up          (init.lua:238)
:q         " close this window
:on        " close every OTHER window
```

New splits open right and below (`splitright` / `splitbelow`, `init.lua:147`), which is
why `:vs` puts the new file where the eye expects it.

The `<C-w>H/J/K/L` maps for *moving* a window (rather than focusing one) are written but
commented out at `init.lua:241-244` — `<C-w>L` still works unmapped.

## 1.4 Recipe: Open the file tree at the file I'm editing

**Problem.** `<leader>e` opens the tree, but at the root, not at the current file.

**Solution.**

```vim
<leader>e                  " toggle the tree            (init.lua:448)
:NvimTreeFindFileToggle    " toggle it, focused on the current file
```

**Discussion.** `update_focused_file.enable = true` (`init.lua:436`) means the tree
follows along once it's open — the `FindFile` variant matters for the *first* open.
`filters.git_ignored = false` (`init.lua:438`) is deliberate: I want to see
`.env.example`, build output, and anything else gitignored, because "invisible in the
tree" is a worse failure than "cluttered tree".

Inside the tree: `<CR>` open, `a` create, `d` delete, `r` rename, `x`/`c`/`p` cut/copy/paste,
`H` toggle hidden, `?` for the full list. `<CR>` on a `.png` renders the image in a
buffer rather than showing bytes — that's `hijack_file_patterns`, see 7.4.

## 1.5 Q&A: Why does the cursor stop 10 lines from the edge?

**Q:** The screen scrolls before my cursor reaches the bottom. Bug?

**A:** `vim.o.scrolloff = 10` (`init.lua:168`). Ten lines of context are always kept above
and below the cursor. `zz` recenters on demand; `:set scrolloff=0` turns it off for a
session.

## 1.6 Technique: Getting back where I was

```
<C-o>      " back along the jumplist
<C-i>      " forward
``         " back to the position before the last jump
`.         " to the last change, wherever it was
gi         " to the last insert position, and enter insert mode
:jumps     " see the whole list
```

`<C-o>` is the one that pays for itself: after `grd` (go to definition, 5.1), it's how you
get home.

---

# 2. Finding things

Telescope is the front door for nearly everything. The whole `<leader>s` family is one
which-key group, "[S]earch" (`init.lua:403`).

| Key | Picker | Line |
|---|---|---|
| `<leader>sf` | Files | `init.lua:633` |
| `<leader>sF` | Files, **including hidden and gitignored** | `init.lua:634` |
| `<leader>sg` | Live grep across the project | `init.lua:639` |
| `<leader>sw` | Grep the word under the cursor (also works on a visual selection) | `init.lua:638` |
| `<leader>s/` | Live grep, **open buffers only** | `init.lua:691` |
| `<leader>/` | Fuzzy find *within* the current buffer | `init.lua:681` |
| `<leader>s.` | Recently opened files | `init.lua:642` |
| `<leader><leader>` | Open buffers | `init.lua:644` |
| `<leader>sd` | Diagnostics | `init.lua:640` |
| `<leader>sh` | Help tags | `init.lua:631` |
| `<leader>sk` | **Keymaps** | `init.lua:632` |
| `<leader>sc` | Ex commands | `init.lua:643` |
| `<leader>ss` | Pick a picker (list of all telescope builtins) | `init.lua:637` |
| `<leader>sr` | **Resume the last picker** | `init.lua:641` |
| `<leader>sn` | Files in this config directory | `init.lua:704` |
| `<leader>gs` | Git status | `init.lua:707` |
| `<leader>fm` | Media files with image preview | `init.lua:710` |
| `<leader>sm` / `sM` / `sG` | Markdown files / all markdown / grep markdown — see 7.3 | `markdown.lua:155` |

## 2.1 Recipe: Find a file telescope refuses to show me

**Problem.** `<leader>sf` can't find `.github/workflows/stylua.yml` or anything gitignored.

**Solution.** `<leader>sF` — same picker with `hidden = true, no_ignore = true`
(`init.lua:634`).

**Discussion.** Capital = "and the stuff you normally don't want". The same convention
holds for markdown: `<leader>sm` is tracked files, `<leader>sM` is everything (7.3).

## 2.2 Recipe: Re-open the search I just closed

**Problem.** Closed a grep result by accident and don't want to retype the query.

**Solution.** `<leader>sr` (`init.lua:641`). Reopens the last picker with its query and
cursor position intact.

## 2.3 Q&A: What are the keys *inside* a picker?

**A:** In insert mode `<C-/>`; in normal mode `?`. That opens a picker of the picker's own
mappings. The ones worth memorizing:

```
<C-n> / <C-p>    next / previous result
<C-u> / <C-d>    scroll the preview
<CR>             open
<C-v>            open in a vertical split
<C-x>            open in a horizontal split
<C-t>            open in a new tab
<C-q>            send ALL results to the quickfix list
<Esc>            close (from insert mode)
```

`<C-q>` is the underused one: grep for a symbol, `<C-q>`, then walk the quickfix list with
`:cn` / `:cp` — a "review every hit" workflow that a picker alone can't give you.

## 2.4 Recipe: Grep, but only inside the files I'm working on

**Problem.** `<leader>sg` on a monorepo returns hundreds of hits from code I'm not touching.

**Solution.** `<leader>s/` — live grep restricted to open buffers (`init.lua:691`).

**Discussion.** Open the four or five files you care about first, then grep. It's a poor
man's scoped search, and much faster to reach for than remembering ripgrep glob flags.

## 2.5 Recipe: Edit this config from anywhere

**Problem.** I'm deep in a project and want to change a keymap.

**Solution.** `<leader>sn` (`init.lua:704`) — a file picker rooted at
`vim.fn.stdpath 'config'`, no matter what the current directory is.

**Discussion.** Paired with `:restart` (10.1), this is the whole edit-config loop without
leaving the session.

---

# 3. Editing techniques

This is the chapter I wrote the file for.

## 3.1 Recipe: Blank out a rectangle of text

**Problem.** A column of text — an aligned comment block, a table column, some inline
values — needs to become spaces, on every one of the selected lines, without disturbing
what's to the left or right.

**Solution.**

```
<C-v>          " enter VISUAL BLOCK mode
j j j          " extend the block DOWN over the lines
l l l          " extend it RIGHT over the columns
r<Space>       " replace every character in the block with a space
```

**Discussion.** This is the recipe I keep coming back for, so, precisely:

- `<C-v>` is *visual block*, distinct from `v` (charwise) and `V` (linewise). The
  selection is a true rectangle: columns N through M on lines A through B.
- `r` in visual mode replaces **every selected character** with the next key you press,
  which is why `r<Space>` blanks and `r-` fills with dashes.
- If the block should run to the end of every line regardless of length, press `$` while
  in block mode — the block becomes ragged-right and `r<Space>` (or `d`) covers all of it.
- To *delete* the rectangle and pull the right-hand text leftward, use `d` instead of
  `r<Space>`. `r<Space>` preserves alignment; `d` collapses it. That's the whole choice.
- `o` in block mode jumps to the opposite corner, so you can extend the selection from
  the side you got wrong without restarting.
- `gv` reselects the same block after you've left it — useful for "blank it, look, undo,
  try again".

The other four things visual block does, which are why it's worth the finger-memory:

| Keys | Effect |
|---|---|
| `<C-v>` + motion + `I` + text + `<Esc>` | **Insert** the text at the start of every line in the block |
| `<C-v>` + motion + `A` + text + `<Esc>` | **Append** it after the block on every line (with `$`, at each line's end) |
| `<C-v>` + motion + `c` + text + `<Esc>` | **Change** — delete the block, then type once, applied to all lines |
| `<C-v>` + motion + `g<C-a>` | Turn a column of zeros into an **incrementing sequence** 1, 2, 3… |

The `<Esc>` matters: with `I`/`A`/`c` the edit is only replicated to the other lines when
you leave insert mode. Type, then `<Esc>`, then watch it multiply.

## 3.2 Technique: Text objects (mini.ai)

`mini.ai` (`init.lua:524-533`) extends the built-in `i`/`a` objects and adds *next* variants.

```
ci'      change inside the quotes
ca'      change the quotes too
va)      visually select around the parentheses
yi]      yank inside the brackets
dap      delete a paragraph
cit      change inside an HTML/XML tag
```

The mini.ai additions, configured with `around_next = 'aa'` and `inside_next = 'ii'`
(`init.lua:528`), search forward up to 500 lines:

```
ciiq     change inside the NEXT quote — cursor doesn't have to be in it yet
yiiq     yank inside the next quote
caa)     change around the next parentheses
```

`ciiq` is the payoff: you don't have to navigate to the string first.

## 3.3 Technique: Surrounding text (mini.surround)

`mini.surround` (`init.lua:536-544`), on the `s` prefix:

```
saiw)    surround inner word with ( )
sa$"     surround to end of line with quotes
sd'      delete the surrounding quotes
sr)'     replace surrounding ) with '
sf / sF  find the next / previous surrounding
```

In visual mode, `sa` + a character wraps the **whole selection** as one span.

Note this shadows built-in `s` (substitute character) in normal mode. `cl` does the same
job.

## 3.4 Recipe: Wrap every line of a selection individually

**Problem.** I have five lines selected and want each one wrapped in backticks or tildes —
`` `line one` ``, `` `line two` `` — not one pair around the whole block. Visual `sa`
(3.3) can't do it; it treats the selection as a single span.

**Solution.** `sel` — [S]urround [E]very [L]ine, my own operator (`markdown.lua:250`).

```
V j j j        " select the lines
sel            " then press one character, e.g. ~ or ` or (
```

**Discussion.** Details worth knowing, all from `markdown.lua:184-250`:

- It prompts `Surround lines N-M with:` and reads **one** character via `getcharstr()`.
- Brackets pair up automatically: `(` or `)` both give `( … )`, and likewise `[`, `{`, `<`.
  Anything else is used verbatim on both sides.
- Indentation and trailing whitespace stay *outside* the markers, so `    foo   ` becomes
  `    ~foo~   ` — the block keeps its shape.
- Blank lines are skipped.
- The whole range is a single `nvim_buf_set_lines` call, so **one `u` undoes all of it**.
- `<Esc>` or `<C-c>` at the prompt aborts.
- It reads the range from `line('v')` and `line('.')`, not `'<` / `'>`, because those
  marks aren't set until visual mode has actually ended.

Known rough edge: markdown list prefixes are included, so `- item` becomes `~- item~`
rather than `- ~item~`. There's an open `TODO(human)` about it at `markdown.lua:203`.

## 3.5 Recipe: Do the same edit on many lines

**Problem.** Twenty lines each need the same three-step fix, and it isn't a
search-and-replace.

**Solution.** Record a macro, then replay it over a range.

```
qw             " start recording into register w
...            " make the edit on ONE line, ending with j to move down
q              " stop recording
@w             " replay once
@@             " replay again (repeats the last @)
20@w           " replay twenty times
:'<,'>normal @w   " replay once per line over a visual selection
```

**Discussion.** The last form is the robust one — counting lines is guesswork, and a
macro that hits the end of the buffer aborts the whole chain anyway. Select the range,
then `:'<,'>normal @w` runs it exactly once per line.

Recording tips that save re-recording:

- Start every macro with `0` or `^` so it doesn't depend on where the cursor happened to be.
- End with `j` so replaying advances.
- Prefer `f(` and `ciw` over `llll` — counted motions break on the first line with
  different spacing.
- A macro is just text in a register: `"wp` pastes it out to look at, and after editing,
  `"wy$` (yank the line back into `w`) fixes it without re-recording. That's how the
  half-finished `w` register in my shada got there.

## 3.6 Technique: Registers

```
"ayy      yank a line into register a
"ap       paste from register a
"+y       yank to the SYSTEM clipboard
"+p       paste from the system clipboard
"0p       paste the last YANK (survives an intervening delete)
".p       paste the last inserted text
"%p       paste the current filename
:reg      show every register
<C-r>a    paste register a while in INSERT mode
```

`clipboard = 'unnamedplus'` (`init.lua:125`) already routes plain `y`/`p` through the
system clipboard, so `"+` is mostly for being explicit.

`"0` is the one that fixes the classic annoyance: `yy`, then `dd` somewhere else, then
`p` — that pastes the deleted line. `"0p` pastes what you actually yanked.

## 3.7 Recipe: Copy the whole file to the system clipboard

**Problem.** I want the entire buffer in the clipboard to paste elsewhere.

**Solution.**

```
ggVG"+y
```

**Discussion.** Read it as four moves: `gg` top, `V` linewise visual, `G` bottom, `"+y`
yank to `+`. `:%y+` is the Ex equivalent and less typing, but the visual version shows you
what you grabbed. For a range: `:10,50y+`.

## 3.8 Technique: Marks

```
ma        set mark a (lowercase = this file)
'a        jump to the LINE of mark a
`a        jump to the exact position
mA        set mark A (uppercase = global, works across files)
'A        jump there from any file
:marks    list them
```

Plus the automatic ones: `` `. `` last change, `` `` `` position before the last jump,
`` `[ `` / `` `] `` bounds of the last yank or paste.

## 3.9 Q&A: How do I repeat the last thing I did?

**A:** `.` — repeats the last *change* (not motion). `d2w` then `.` deletes another two
words. Combined with `n` from a search, `n.n.n.` is a manual, look-before-you-leap
substitute.

`gv` reselects the last visual selection. `` `` `` returns to where you were before the
last jump. `@:` repeats the last **Ex** command — the `:` register is a register like any
other.

---

# 4. Search and replace

## 4.1 Recipe: Search for a whole word, not a substring

**Problem.** Searching `id` matches `width`, `valid`, `identity`…

**Solution.** Word boundaries:

```
/\<id\>
```

**Discussion.** `\<` and `\>` are zero-width word boundaries. `*` on a word under the
cursor does this for you (and `#` searches backwards). The escaped angle brackets are
vim's regex flavor, not PCRE — if you'd rather write PCRE-ish patterns, prefix with `\v`
(very magic) and it becomes `/\v<id>`.

## 4.2 Q&A: Why is my lowercase search matching uppercase?

**A:** `ignorecase = true` **plus** `smartcase = true` (`init.lua:134-135`). All-lowercase
searches are case-insensitive; the moment you type one capital, the search becomes
case-sensitive. `/foo` matches `Foo`; `/Foo` does not match `foo`. Force it either way
with `\c` or `\C` anywhere in the pattern.

## 4.3 Recipe: Replace across the file, with a look at each one

**Problem.** Rename a variable everywhere, but a couple of the hits are wrong.

**Solution.**

```vim
:%s/old/new/gc
```

**Discussion.** `%` = whole file, `g` = every occurrence per line, `c` = confirm each.
At the prompt: `y` yes, `n` no, `a` all the rest, `q` quit, `l` this one then stop.

Two shortcuts that matter:

- **Leave the pattern empty to reuse the last search.** Search `/\<oldName\>` first, eyeball
  the matches with `n`, then `:%s//newName/g`. No retyping and no risk of a typo in the
  second copy of the pattern.
- **`inccommand = 'split'`** (`init.lua:162`) previews the substitution live in a split
  as you type it — every affected line, before you press `<CR>`. It turns `:%s` from a
  leap of faith into something you can watch.

Ranges: `:s` current line, `:'<,'>s` the visual selection, `:10,20s` explicit lines,
`:.,+5s` from here down five, `:.,$s` to the end of the file.

## 4.4 Recipe: Run a command on every line that matches something

**Problem.** Delete every line containing `console.log`, or comment out every line with
`TODO`.

**Solution.**

```vim
:g/console\.log/d              " delete matching lines
:g/TODO/normal I// <Esc>       " prepend // to matching lines
:v/keep/d                      " delete every line that does NOT match
:g/pattern/normal @w           " run macro w on every matching line
```

**Discussion.** `:g` is the sharpest tool in Ex: *find every line matching this, run that
command on it*. `:normal` lets the command be arbitrary normal-mode keys, which means
anything you can do by hand you can do to every match at once. `:v` (or `:g!`) inverts
the match. Undo is one `u` for the whole sweep.

## 4.5 Technique: Line ranges and jumping

```vim
:52          " jump to line 52
:$           " last line
:.,.+6d      " delete from this line down 6
:.,$y+       " yank from here to the end into the clipboard
52G          " normal-mode jump to line 52
```

`:.,.+6` reads as "from the current line (`.`) to six past it". Every Ex command takes a
range in that form.

## 4.6 Q&A: How do I clear the search highlight?

**A:** `<Esc>` in normal mode (`init.lua:186`) — mapped to `:nohlsearch`. In stock vim you'd
need `:noh`.

---

# 5. Code intelligence (LSP)

Attached servers: `ts_ls` (TS/JS), `pyright` + `ruff` (Python), `bashls`, `lua_ls`
(`init.lua:826-865`). Mason installs them; `mason-tool-installer` keeps them present.

The mappings live on the `gr` prefix, registered as a which-key group "LSP Actions"
(`init.lua:407`), and are all **buffer-local** — they only exist where a server is attached.

| Key | Action | Line |
|---|---|---|
| `grd` | Go to definition (telescope picker) | `init.lua:663` |
| `grr` | References | `init.lua:654` |
| `gri` | Implementations | `init.lua:658` |
| `grt` | Type definition | `init.lua:676` |
| `grD` | **Declaration** — not definition; in C, the header | `init.lua:775` |
| `grn` | Rename symbol, across files | `init.lua:767` |
| `gra` | Code action (normal and visual) | `init.lua:771` |
| `gO` | Document symbols — outline of this file | `init.lua:667` |
| `gW` | Workspace symbols — search the whole project | `init.lua:671` |
| `K` | Hover documentation (built-in) | — |
| `<leader>th` | Toggle inlay hints (only if the server supports them) | `init.lua:811` |
| `<leader>q` | Send diagnostics to the location list | `init.lua:215` |
| `<leader>sd` | Diagnostics in telescope | `init.lua:640` |
| `<leader>f` | Format buffer (conform, async; normal and visual) | `init.lua:940` |

## 5.1 Recipe: Read code I don't know

**Problem.** Landing in an unfamiliar file and needing to understand its shape.

**Solution.**

```
gO         " outline of this file — every symbol, fuzzy-searchable
grd        " jump to a definition
<C-o>      " come back
grr        " who calls this?
K          " what does it do?
gW         " find a symbol anywhere in the project by name
```

**Discussion.** `gO` then `<C-o>` is the loop. Because `grd`/`grr` go through telescope
(`init.lua:648-678` — that's my change; stock kickstart uses the plain LSP handlers), a
symbol with fifteen references gives you a searchable, previewable list instead of
dumping you at the first one.

## 5.2 Q&A: Where did the inline error text go?

**A:** I turned it off. `virtual_text = false` and `virtual_lines = { only_current_line =
true }` (`init.lua:199-201`, marked `@my_changes`). Diagnostics render as full lines
**below the cursor line only**, instead of trailing every broken line at once. Quieter,
and the message doesn't get truncated at the window edge.

The rest of that config: `update_in_insert = false` (no diagnostics churning while you
type), `severity_sort = true`, `underline` only at WARN and above, and jumping to a
diagnostic auto-opens a rounded float at the cursor.

To see everything at once: `<leader>sd` (telescope) or `<leader>q` (location list, then
`:lne` / `:lp`).

## 5.3 Recipe: Inspect diagnostics or clients as data

**Problem.** A server is misbehaving and I want the raw facts, not the UI.

**Solution.**

```vim
:lua =vim.diagnostic.get(0)
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
:checkhealth lsp
```

**Discussion.** `:lua =expr` is shorthand for `:lua print(vim.inspect(expr))` — the `=`
does the pretty-printing. `0` means the current buffer.

`:LspInfo` is gone in 0.12, and `vim.lsp.get_active_clients()` is deprecated in favor of
`get_clients()`. I typed both before learning that; `:checkhealth lsp` is the replacement
for the first.

## 5.4 Q&A: What are blink.cmp's completion keys?

**A:** The `default` preset (`init.lua:987`, documented at `init.lua:979-984`):

```
<C-y>       accept the selected item
<C-n>       next item          (or <Down>)
<C-p>       previous item      (or <Up>)
<C-space>   open the menu; if open, open the documentation
<C-e>       dismiss
<C-k>       toggle signature help
<Tab>/<S-Tab>  move between placeholders inside an expanded snippet
```

`<C-y>` accepts, not `<CR>` — that's the one that trips me up. Docs don't auto-show
(`auto_show = false`, `init.lua:1002`); `<C-space>` twice gets them.

## 5.5 Recipe: Format a file

**Problem.** Reformat, or reformat just part of a file.

**Solution.** `<leader>f` (`init.lua:940`) — works in normal mode (whole buffer) and
visual mode (selection only).

**Discussion.** conform runs format-on-save **for Python only** (`init.lua:913-928`);
`ruff_fix` then `ruff_format`. Lua's entry is commented out. Everything else formats
through the LSP as a fallback (`lsp_format = 'fallback'`) when you ask for it explicitly.

`lua_ls` has formatting disabled on purpose (`init.lua:839, 863`) so stylua owns Lua
style — see D.1 for the wrinkle in how stylua gets installed.

---

# 6. Git

Only three keys, all from gitsigns' `on_attach` (`init.lua:389-392`) and therefore
buffer-local.

| Key | Action |
|---|---|
| `]c` | Next changed hunk |
| `[c` | Previous changed hunk |
| `<leader>hp` | Preview the hunk under the cursor |
| `<leader>gs` | Telescope git status (`init.lua:707`) |

The gutter glyphs are `+` add, `~` change, `_` delete, `‾` top-delete, `~` changedelete
(`init.lua:378-384`).

## 6.1 Recipe: Review my own diff before committing

**Problem.** I want to see what changed without leaving nvim.

**Solution.**

```
<leader>gs      " telescope: pick a changed file
]c              " walk to the next hunk
<leader>hp      " see what it was before
```

**Discussion.** The full gitsigns keymap set is now wired directly into the
`on_attach` in `init.lua`, not pulled from `lua/kickstart/plugins/gitsigns.lua`.
That file stays commented out on purpose: it calls `gitsigns.setup()` a second
time, which would overwrite the custom `signs` table. Anything gitsigns doesn't
cover still goes through the shell (9.2).

| Key | Does |
|---|---|
| `<leader>hs` / `<leader>hr` | Stage / reset the hunk (also works on a visual selection) |
| `<leader>hS` / `<leader>hR` | Stage / reset the whole buffer |
| `<leader>hp` / `<leader>hi` | Preview the hunk in a popup / inline |
| `<leader>hd` / `<leader>hD` | Diff against the index / the last commit |
| `<leader>hq` / `<leader>hQ` | Send hunks to the quickfix list (this file / all files) |
| `dih`, `vih` | The hunk as a text object |

---

## 6.2 Technique: Blame, in three levels of detail

**Problem.** "Who wrote this line, and why?" has three different answers depending
on how much context I need, and reaching for the wrong one wastes time.

**Solution.** Start passive, escalate on demand.

```
                " level 1: always on, no keypress.
                " ghost text at end of line, follows the cursor:
                "     Jane Doe, 3 months ago · fix null check
<leader>tb      " toggle that off when it gets noisy

<leader>gb      " level 2: popup for THIS line — full commit message + the
                " diff hunk that introduced it

<leader>gB      " level 3: full-file blame in a scroll-bound split, the
                " closest thing to the GitHub blame view.
                " <CR> on a line opens that commit and re-blames through its
                " parent, so you can walk backwards through history.
```

**Discussion.** Level 1 is `current_line_blame` and it's on at startup. Three
settings make it liveable, all in the `gitsigns.setup` call:

- `delay = 300` — the default 1000ms feels laggy when scanning a file. Under
  about 150ms it flickers while navigating.
- `ignore_whitespace = true` — without this, a single reformat commit claims
  every line in the file. This is the setting that makes always-on blame
  tolerable rather than actively misleading.
- `use_focus = true` — blame renders only in the focused window, so splits
  don't fill with ghost text.

The format string is `'  <author>, <author_time:%R> · <summary>'`. `%R` is
relative time; swap it for `%Y-%m-%d` if absolute dates read better. Setting
`virt_text_pos = 'right_align'` instead of `'eol'` pins blame to the window
edge, which is closer to how GitHub lays it out — worth trying both.

**Q: Is there a hover-style blame, like an LSP hover?**
No, and it isn't missed. `<leader>gb` is the on-demand version and the inline
ghost text is the passive one; between them there's nothing a hover would add.

**Q: What about opening the line's commit on GitHub?**
Not wired up. gitsigns doesn't do it — that needs something like
`ruifm/gitlinker.nvim` or snacks.nvim's `gitbrowse`. Deliberately left out
until it's actually wanted.

---

# 7. Markdown, images, and previews

All of this lives in `lua/custom/plugins/markdown.lua`, which only became live when
`require 'custom.plugins'` was uncommented at `init.lua:1313` — the directory was dead
code before that. Files there are auto-loaded: drop in `lua/custom/plugins/anything.lua`
and it's required at startup.

## 7.1 Recipe: Read markdown as formatted text, in place

**Problem.** Raw `#`, `**`, and `|` are noise when reading a long document.

**Solution.** `<leader>tm` (`markdown.lua:33`) — toggles render-markdown.nvim.

**Discussion.** Headings render inline with block-width backgrounds, code blocks get a
thin border, checkboxes become `󰄱`/`󰱒`. `anti_conceal` is on, so the line under the cursor
reverts to raw source — you can edit the real text while the rest stays pretty. Rendering
is active in normal, command, and terminal modes (`render_modes`, `markdown.lua:22`), so
it drops away in insert mode automatically. LaTeX is off.

## 7.2 Recipe: Full-page markdown preview

**Problem.** I want to see the whole document rendered, like a reader would.

**Solution.** `<leader>mp` or `:Glow` (`markdown.lua:81`). `q` closes it.

**Discussion.** Opens a centered floating window — `min(120, 90% of columns)` wide, 85%
of the screen tall — running `glow -p` in a terminal buffer (`markdown.lua:41-79`).
`:Glow path/to/other.md` previews a different file; with no argument it previews the
current buffer. Needs `brew install glow`, and says so if it's missing.

Difference from 7.1: `<leader>tm` renders *in the buffer you're editing*; `<leader>mp` is
a separate read-only pager you dismiss.

## 7.3 Recipe: Find notes among a pile of code

**Problem.** `<leader>sf` in a big repo buries the handful of `.md` files under source.

**Solution.**

| Key | Does |
|---|---|
| `<leader>sm` | Markdown files only (`.md`, `.markdown`, `.mdx`) |
| `<leader>sM` | The same, including hidden and gitignored |
| `<leader>sG` | Live grep restricted to markdown |

**Discussion.** A hand-rolled telescope extension (`markdown.lua:86-172`), registered so
`:Telescope markdown` works too. It shells out to `rg --files` with the globs.

Two extra keys **inside** that picker, in both insert and normal mode:

- `<C-g>` — close the picker and open the highlighted file in the glow float (7.2)
- `<C-y>` — copy the file's relative path to the clipboard, without closing

All the default telescope mappings (2.3) still work.

## 7.4 Recipe: Look at an image without leaving the editor

**Problem.** A screenshot or diagram in the repo, and switching to a file browser breaks
flow.

**Solution.**

- `<CR>` on the file in nvim-tree, or `:e shot.png` — it renders as an image, not bytes
- `<leader>fm` — the media picker, with previews as you move the cursor
- `<leader>ti` or `:ImageToggle` — turn inline images off when they're in the way

**Discussion.** The `<CR>` behavior is `hijack_file_patterns` (`init.lua:490`), covering
png, jpg, jpeg, gif, webp, avif, and svg. Images in markdown render inline too
(`integrations.markdown`).

`<leader>ti` (`init.lua:507`) exists because images are **pixels painted over the
window** — they can't reflow around text, so they cover things while you edit. It mirrors
`<leader>tm` for the same reason.

`<leader>fm` (`init.lua:710`) is telescope-media-files, which shells out to `chafa` for
raster previews, `rsvg-convert` for SVG, and `pdftoppm` (poppler) for PDF.

## 7.5 Q&A: Why don't images show up in some terminals?

**A:** There is no single protocol for pushing pixels into a terminal. Kitty, WezTerm,
and Ghostty speak the **kitty** protocol; iTerm2, foot, and Windows Terminal speak
**sixel**. Pick wrong and images silently never appear — no error, just nothing.

So the backend is detected at startup (`image_backend()`, `init.lua:459-466`):
`$IMAGE_NVIM_BACKEND` if set, else `sixel` for iTerm2, else `kitty` for
WezTerm/Ghostty/Kitty, else `sixel` as the wider-support default. To override:

```sh
IMAGE_NVIM_BACKEND=kitty nvim
```

Also needs `imagemagick` installed to decode and resize — that missing binary is why this
feature appeared to work for four days while rendering nothing (see E, 2026-09-01).

---

# 8. Debugging Python

nvim-dap with dap-ui and virtual text (`init.lua:1091-1130`). This section is mine, not
kickstart's.

| Key | Action |
|---|---|
| `<F5>` | Start / continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>du` | Toggle the debug UI panel |
| `<leader>dr` | Toggle the REPL |
| `<leader>dt` | Debug the test method under the cursor |

## 8.1 Recipe: Break on a line and inspect state

**Problem.** Print-debugging a Python function.

**Solution.**

```
<leader>db     " breakpoint on this line
<F5>           " start — the UI opens by itself
<F10>/<F11>    " step over / into
<leader>dr     " a REPL in the paused frame
<F5>           " continue to the end; the UI closes by itself
```

**Discussion.** dap-ui opens on `event_initialized` and closes on `event_terminated` /
`event_exited` (`init.lua:1116-1118`) — no manual toggling in the common case.
nvim-dap-virtual-text prints each variable's live value inline next to its name while
paused, which is most of what you wanted from the UI anyway.

The interpreter is `<cwd>/.venv/bin/python` when that exists, else `python3`
(`init.lua:1112`) — so **launch nvim from the project root** or it picks the wrong
environment. `debugpy` must be installed in that venv.

`<leader>dt` (`init.lua:1127`) is dap-python's `test_method()`: put the cursor inside a
test function and it debugs that test alone.

Note there's no which-key group registered for `<leader>d`, so the popup shows the keys
without a heading.

---

# 9. Terminal and shell

## 9.1 Recipe: Get a shell inside nvim, and back out

**Problem.** `:term` gives a shell, but then `<Esc>` is eaten by the shell and I'm stuck.

**Solution.**

```vim
:term          " terminal in the current window
:sp | term     " terminal in a split
<Esc><Esc>     " leave terminal mode back to normal mode   (init.lua:223)
i              " re-enter terminal mode
```

**Discussion.** A terminal buffer has its own mode: keys go to the program, not to vim.
The double-`<Esc>` maps to `<C-\><C-n>`, the built-in escape, which single `<Esc>` can't
be without breaking every TUI running inside. Once out, it's an ordinary buffer — scroll
it, search it, yank from it.

## 9.2 Technique: One-off shell commands

```vim
:!ls -la              " run it, show output, wait for a key
:!make test           " same
:r !date              " READ the output into the buffer below the cursor
:%!jq .               " FILTER the whole buffer through jq, replacing it
:'<,'>!sort           " filter just the selection through sort
:!%:h                 " %:h expands to the current file's directory
```

`:r !cmd` and `:%!cmd` are the two worth internalizing: one pulls output *in*, the other
pipes the buffer *through* a program and takes the result. `:%!sort`, `:%!jq .`, and
`:'<,'>!column -t` cover a surprising amount of ground.

Useful `%` modifiers: `%` full path, `%:h` directory, `%:t` filename, `%:r` without
extension.

---

# 10. Living with the config

## 10.1 Recipe: Apply a config change I just made

**Problem.** Edited `init.lua`; the change doesn't take effect.

**Solution.**

```vim
:source $MYVIMRC     " or :source % while editing init.lua
:restart             " what I actually use
```

**Discussion.** This is the thing I got wrong repeatedly.

`:source` re-executes the file, but plugin `setup {}` calls are **not idempotent**.
Re-sourcing re-registers autocmds and keymaps, can double up handlers, and often leaves a
half-applied state — options and mappings update, plugin internals don't. Symptoms are
confusing precisely because *some* of the change appears.

`:restart` (Neovim 0.11+, and confirmed present here on 0.12.4) restarts the editor in
place, keeping the terminal session. Two seconds, zero ambiguity. Use `:source` only for
a quick option or keymap tweak you're about to iterate on.

`$MYVIMRC` is the path to the loaded init file — `:echo $MYVIMRC` prints it.

## 10.2 Recipe: Find out what a key is bound to, and who bound it

**Problem.** A key does something unexpected, or I want to know if a mapping is free.

**Solution.**

```vim
<leader>sk                    " telescope keymaps — fuzzy search everything
:verbose nmap U               " what U does AND which file set it
:nmap <leader>g               " every normal-mode map starting with <leader>g
:map                          " everything (long)
:redir @+ | nmap | redir END  " dump all normal-mode maps to the clipboard
```

**Discussion.** `:verbose` is the important half — it appends "Last set from
/path/to/file line N", which turns "why is this weird" into a file and a line number.

`:redir @+ | cmd | redir END` is the general trick: redirect any command's output into a
register (`@+` = clipboard, `@a` = register a) instead of the message area. Useful when
the output scrolls past.

`<leader>sk` supersedes all of it day to day — searchable, shows descriptions, and every
mapping in this config has one.

And just pressing `<leader>` and waiting is the fastest: which-key pops up with
`delay = 0` (`init.lua:400`). Groups defined at `init.lua:403-409`: `<leader>s` Search,
`<leader>t` Toggle, `<leader>g` Git, `<leader>h` Git Hunk, `gr` LSP Actions. (`<leader>d`,
`<leader>m`, and `<leader>f` have no group registered — they still work, just without a
heading.)

## 10.3 Recipe: Diagnose a plugin that isn't working

**Problem.** Something's installed but does nothing.

**Solution.**

```vim
:checkhealth                 " everything
:checkhealth blink.cmp       " one plugin
:checkhealth telescope
:checkhealth lsp
:checkhealth kickstart       " this config's own check: nvim >= 0.12, git, make, unzip, rg
:messages                    " errors that scrolled past at startup
```

**Discussion.** `:checkhealth <name>` is the first move, always. Most "plugin is broken"
turns out to be a missing external binary, and health checks name it. `:messages` catches
startup errors you blinked past — a Lua error in one plugin's setup can silently skip
everything after it in the same block.

## 10.4 Q&A: How do plugins work here — there's no `lazy.nvim`?

**A:** This fork uses Neovim 0.12's built-in **`vim.pack`**. Plugins are declared with
`vim.pack.add { ... }` right where they're configured, so declaration and `setup {}` sit
together in `init.lua` instead of in separate spec files.

```vim
:lua vim.pack.update()                    " update everything
:lua vim.pack.update({ 'blink.cmp' })     " update one
:help vim.pack                            " the docs
```

Versions are pinned in `nvim-pack-lock.json` (29 plugins, committed in this fork — stock
kickstart gitignores it). Some are constrained in code: LuaSnip `2.*`, blink.cmp `1.*`,
nvim-treesitter to branch `main` (`init.lua:952, 963, 1036`).

Plugins live on disk at `~/.local/share/nvim/site/pack/core/opt/`. Occasionally useful
directly — building blink.cmp's optional Rust matcher, for instance:

```sh
cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp && cargo build --release
```

Though `fuzzy.implementation = 'lua'` (`init.lua:1018`) means the pure-Lua matcher is in
use and that build isn't required.

Build steps run from a `PackChanged` autocmd (`init.lua:320-342`): `make` for
telescope-fzf-native, `make install_jsregexp` for LuaSnip, `TSUpdate` for treesitter.
fzf-native is only added at all if `make` exists (`init.lua:326`).

## 10.5 Recipe: Add a language server, formatter, or parser

**Problem.** Starting work in a language nothing is configured for.

**Solution.**

- **LSP server** — add it to the `servers` table (`init.lua:826-865`) as `name = {}`.
  mason-tool-installer installs it on next start; the loop at `init.lua:898` enables it.
  `:Mason` for the interactive installer, `:Mason` + `X` to uninstall.
- **Formatter** — add to `formatters_by_ft` in conform (`init.lua:929`). Add the filetype
  to the `format_on_save` list (`init.lua:917`) if it should run automatically.
- **Treesitter parser** — `:TSInstall <lang>`, or add it to `ensure_installed`
  (`init.lua:1039`). `:TSUpdate` refreshes all of them.

**Discussion.** A `FileType` autocmd (`init.lua:1064-1084`) auto-installs a missing parser
the first time you open a file of that type, so `:TSInstall` is mostly for pre-warming.

Currently installed eagerly: bash, c, diff, html, lua, luadoc, markdown, markdown_inline,
query, vim, vimdoc. Treesitter folding is available but commented out
(`init.lua:1052-1053`).

## 10.6 Q&A: Why does my file save itself?

**A:** A `vim.uv` timer fires every 1000 ms and runs `silent! noautocmd write` on any
buffer that is modified, normal (`buftype == ''`), modifiable, and has a filename
(`init.lua:271-276`).

The `noautocmd` is load-bearing: without it, every single second would trigger
`BufWritePre`/`BufWritePost` — running conform's format-on-save and firing fidget
notifications continuously. A manual `:w` still runs autocmds normally, so Python still
formats on a real save.

A second 1000 ms timer runs `checktime` (`init.lua:253-256`) to reload files changed
outside the editor — polling rather than relying on `FocusGained`, which terminals report
inconsistently. `vim.o.autoread = true` (`init.lua:252`) makes the reload automatic.

## 10.7 Recipe: Try on colorschemes

**Problem.** Deciding which scheme to use, without editing config for each one.

**Solution.**

```vim
:colorscheme <Tab>       " cycle through the available names
:colorscheme industry    " try one immediately
```

Or step through every installed scheme, pressing Enter between:

```vim
:lua for _, c in ipairs(vim.fn.getcompletion('', 'color')) do vim.cmd('colorscheme ' .. c) vim.fn.input(c .. ' - press Enter for next') end
```

**Discussion.** `:colorscheme` applies instantly and is not persistent — restart and
you're back to whatever `init.lua` sets. To make it stick, edit `vim.cmd.colorscheme` at
`init.lua:429`.

`getcompletion('', 'color')` is the general pattern for "what are the valid values here?" —
it works for any completion type: `'command'`, `'filetype'`, `'help'`, `'option'`.

## 10.8 Q&A: How do I read the docs?

```vim
:help                  " the front page
:help vim.keymap.set   " a specific function
:help :normal          " an Ex command (note the leading colon)
:help 'scrolloff'      " an option (note the quotes)
:help i_CTRL-R         " an insert-mode key
<leader>sh             " fuzzy-search all help tags
<C-]>                  " follow the tag under the cursor
<C-o>                  " back
```

The sigils are the trick: `:cmd` for commands, `'opt'` for options, `i_` / `v_` / `c_`
prefixes for mode-specific keys. `<leader>sh` sidesteps needing to remember any of it.

`:help kickstart` opens this config's own doc (`doc/kickstart.txt`). Note `:Tutor` is
**not** available in 0.12.4 — it's been unbundled.

---

# Appendix A: Every keymap

Leader is `<Space>`. Everything below is from this repo; `→` means "defined at".

### Core

| Mode | Key | Action | → |
|---|---|---|---|
| n | `<Esc>` | Clear search highlight | `init.lua:186` |
| n | `<leader>q` | Diagnostics to location list | `init.lua:215` |
| n | `<leader>e` | Toggle file tree | `init.lua:448` |
| n, v | `<leader>f` | Format buffer | `init.lua:940` |
| t | `<Esc><Esc>` | Leave terminal mode | `init.lua:223` |
| n | `<C-h>` / `<C-l>` / `<C-j>` / `<C-k>` | Focus window left / right / down / up | `init.lua:235-238` |

### Search — `<leader>s`

| Key | Action | → |
|---|---|---|
| `<leader><leader>` | Buffers | `init.lua:644` |
| `<leader>/` | Fuzzy find in this buffer | `init.lua:681` |
| `<leader>sf` / `<leader>sF` | Files / files incl. hidden + ignored | `init.lua:633-636` |
| `<leader>sg` | Live grep | `init.lua:639` |
| `<leader>sw` (n, v) | Grep word under cursor | `init.lua:638` |
| `<leader>s/` | Live grep in open buffers | `init.lua:691` |
| `<leader>s.` | Recent files | `init.lua:642` |
| `<leader>sd` | Diagnostics | `init.lua:640` |
| `<leader>sh` | Help tags | `init.lua:631` |
| `<leader>sk` | Keymaps | `init.lua:632` |
| `<leader>sc` | Commands | `init.lua:643` |
| `<leader>ss` | Pick a telescope picker | `init.lua:637` |
| `<leader>sr` | Resume last picker | `init.lua:641` |
| `<leader>sn` | Files in this config | `init.lua:704` |
| `<leader>sm` / `<leader>sM` | Markdown / all markdown | `markdown.lua:155-158` |
| `<leader>sG` | Grep markdown only | `markdown.lua:161` |

### Toggle — `<leader>t`

| Key | Action | → |
|---|---|---|
| `<leader>tm` | Markdown rendering | `markdown.lua:33` |
| `<leader>ti` | Inline images | `init.lua:507` |
| `<leader>th` | LSP inlay hints | `init.lua:811` |

### LSP — `gr` and friends

| Key | Action | → |
|---|---|---|
| `grd` / `grr` / `gri` / `grt` | Definition / references / implementations / type def | `init.lua:654-676` |
| `grD` | Declaration | `init.lua:775` |
| `grn` | Rename | `init.lua:767` |
| `gra` (n, x) | Code action | `init.lua:771` |
| `gO` / `gW` | Document / workspace symbols | `init.lua:667-671` |

### Git

| Key | Action | → |
|---|---|---|
| `]c` / `[c` | Next / previous hunk | `init.lua:389-390` |
| `<leader>hp` | Preview hunk | `init.lua:392` |
| `<leader>gs` | Git status picker | `init.lua:707` |

### Debug — `<leader>d` and F-keys

| Key | Action | → |
|---|---|---|
| `<F5>` / `<F10>` / `<F11>` / `<F12>` | Continue / over / into / out | `init.lua:1120-1123` |
| `<leader>db` / `<leader>dr` / `<leader>du` | Breakpoint / REPL / UI | `init.lua:1124-1126` |
| `<leader>dt` | Debug test under cursor | `init.lua:1127` |

### Markdown, media, and the custom operator

| Mode | Key | Action | → |
|---|---|---|---|
| n | `<leader>mp` | Glow preview float | `markdown.lua:81` |
| n | `<leader>fm` | Media file picker | `init.lua:710` |
| **x** | **`sel`** | **Surround every line** (3.4) | `markdown.lua:250` |

### Buffer-local, inside things

| Where | Key | Action |
|---|---|---|
| Glow float | `q` | Close (`markdown.lua:71`) |
| `:Telescope markdown` | `<C-g>` | Open highlighted file in glow |
| `:Telescope markdown` | `<C-y>` | Yank relative path |
| Any picker | `<C-/>` (i) / `?` (n) | Show that picker's keymaps |

### Implicit — from mini.nvim (no explicit `keymap.set`)

`mini.ai`: `i` / `a` text objects plus `ii` / `aa` for the *next* one (3.2).
`mini.surround`: `sa` add, `sd` delete, `sr` replace, `sf` / `sF` find (3.3).

---

# Appendix B: Plugins

29, all pinned in `nvim-pack-lock.json`.

### UI and core UX

| Plugin | What it gives me |
|---|---|
| `nvim-mini/mini.nvim` | Four modules: `mini.ai` (text objects), `mini.surround`, `mini.statusline`, `mini.icons` (mocking nvim-web-devicons) |
| `nvim-tree/nvim-tree.lua` | File tree on `<leader>e` |
| `nvim-tree/nvim-web-devicons` | Filetype icons |
| `folke/which-key.nvim` | The pending-keybind popup — the reason I can forget mappings |
| `folke/tokyonight.nvim` | Colorscheme, installed and configured but **not loaded** (D.2) |
| `folke/todo-comments.nvim` | Highlights TODO / NOTE / FIX in comments (signs off) |
| `lewis6991/gitsigns.nvim` | Git gutter + hunk navigation |
| `NMAC427/guess-indent.nvim` | Detects a file's indentation instead of forcing mine |
| `j-hui/fidget.nvim` | LSP progress spinner in the corner |
| `3rd/image.nvim` | Inline images and SVG (7.4, 7.5) |

### Search

| Plugin | What it gives me |
|---|---|
| `nvim-telescope/telescope.nvim` | Every picker in chapter 2 |
| `nvim-telescope/telescope-fzf-native.nvim` | Native fuzzy sorter — only added if `make` exists |
| `nvim-telescope/telescope-ui-select.nvim` | Routes `vim.ui.select` (code actions, etc.) through telescope |
| `nvim-telescope/telescope-media-files.nvim` | `<leader>fm` — png/jpg/gif/svg/webp/pdf previews |
| `nvim-lua/plenary.nvim` | Lua library telescope depends on |

### LSP, completion, syntax

| Plugin | What it gives me |
|---|---|
| `neovim/nvim-lspconfig` | Server configurations |
| `mason-org/mason.nvim` | `:Mason` — installs servers and tools |
| `mason-org/mason-lspconfig.nvim` | Name translation between the two (`automatic_enable = false`) |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Auto-installs everything in the `servers` table |
| `saghen/blink.cmp` | Completion (5.4). Pinned `1.*` |
| `L3MON4D3/LuaSnip` | Snippet engine. Pinned `2.*` |
| `stevearc/conform.nvim` | Formatting, `<leader>f` |
| `nvim-treesitter/nvim-treesitter` | Highlighting and indentation. Pinned to `main` |

### Debug

| Plugin | What it gives me |
|---|---|
| `mfussenegger/nvim-dap` | The debug adapter protocol client |
| `rcarriga/nvim-dap-ui` | Scopes / stacks / watches panel |
| `mfussenegger/nvim-dap-python` | Python adapter and `<leader>dt` |
| `theHamsta/nvim-dap-virtual-text` | Live variable values inline |
| `nvim-neotest/nvim-nio` | Async library dap-ui needs |

### Markdown

| Plugin | What it gives me |
|---|---|
| `MeanderingProgrammer/render-markdown.nvim` | `<leader>tm` in-buffer rendering |

### Available but switched off

All six live under `lua/kickstart/plugins/`, commented out at `init.lua:1303-1308`:

| File | Would add | Why it's off |
|---|---|---|
| `neo-tree.lua` | neo-tree file tree on `\` | Superseded by nvim-tree |
| `debug.lua` | DAP for **Go** (delve) with different F-keys | Would collide with my Python DAP — see D.4 |
| `gitsigns.lua` | The full gitsigns keymap set (stage / reset / blame) | Equivalent maps are wired directly into `on_attach` instead; this file would re-run `setup()` and clobber the custom `signs` table |
| `lint.lua` | nvim-lint, markdownlint for markdown | Python linting comes from the `ruff` LSP instead |
| `indent_line.lua` | indent-blankline guide lines | Not enabled |
| `autopairs.lua` | Automatic bracket pairs | Not enabled |

Uncommenting the `require` line is all it takes.

---

# Appendix C: External binaries

Everything below was verified present on 2026-09-01.

| Binary | Install | Needed for | Without it |
|---|---|---|---|
| `git` | — | vim.pack, gitsigns | Nothing installs |
| `make` | Xcode CLT | telescope-fzf-native, LuaSnip regex | fzf-native is skipped entirely (`init.lua:326`) |
| `gcc` | Xcode CLT | Treesitter parser compilation | No syntax highlighting for new languages |
| `unzip` | — | Mason downloads | Servers fail to install |
| `rg` | `brew install ripgrep` | Live grep, markdown picker | `<leader>sg`, `<leader>sm` dead |
| `fd` | `brew install fd` | File finding | Slower `<leader>sf` |
| `magick` | `brew install imagemagick` | image.nvim decode/resize | **Images silently never render** (7.5) |
| `rsvg-convert` | `brew install librsvg` | SVG rasterization | SVGs don't render |
| `chafa` | `brew install chafa` | telescope-media-files previews | `<leader>fm` shows no preview |
| `pdftoppm` | `brew install poppler` | PDF previews in `<leader>fm` | PDFs don't preview |
| `glow` | `brew install glow` | `:Glow` / `<leader>mp` | The float errors with a hint |
| `node` | `brew install node` | `ts_ls` | No TS/JS LSP |
| `python3` + `debugpy` in `.venv` | project venv | nvim-dap-python | `<F5>` can't attach |
| `cargo` | rustup | Optional blink.cmp Rust matcher | Nothing — the Lua matcher is in use |

A Nerd Font is assumed: `vim.g.have_nerd_font = true` (`init.lua:102`). Without one,
icons render as boxes; flip that to `false`.

---

# Appendix D: Gotchas in my own config

The things that would confuse me in six months.

## D.1 `stylua` sits in the LSP servers table

`init.lua:832` has `stylua = {}` inside `servers`. stylua is a **formatter**, not a
language server — there's no lspconfig entry for it. It's there so mason-tool-installer
(which reads `vim.tbl_keys(servers)`) installs it. Harmless, but it also gets passed to
`vim.lsp.config` / `vim.lsp.enable`, which is meaningless for it. The clean fix is the
`vim.list_extend` list at `init.lua:892-894`, which exists for exactly this and is
currently empty.

## D.2 tokyonight is installed but not used

`init.lua:418-429` adds tokyonight, configures `styles.comments.italic = false`… and then
`vim.cmd.colorscheme 'industry'` runs — a *built-in* scheme. The plugin loads and does
nothing. Not a bug, just a leftover of trying schemes (10.7); switching back is a
one-line edit.

## D.3 Two one-second timers are always running

Autosave and `checktime` (10.6). If saves-per-second ever cause trouble with a file
watcher or a build tool, `init.lua:271-276` is where to look, not any plugin.

## D.4 Two DAP setups would fight

Section 9.5 (`init.lua:1091-1130`) sets up nvim-dap for **Python** on `<F5>`/`<F10>`/
`<F11>`/`<F12>` and `<leader>d…`. `lua/kickstart/plugins/debug.lua` sets up nvim-dap for
**Go** on `<F1>`/`<F2>`/`<F3>`/`<F7>` and `<leader>b`/`<leader>B`. Uncommenting
`init.lua:1146` would run both `setup` calls and leave two overlapping keymap schemes.
Merge, don't stack.

## D.5 `sel` includes markdown list prefixes

`- item` becomes `~- item~`, not `- ~item~`. Open `TODO(human)` at `markdown.lua:203`.

## D.6 `lua/custom/plugins/` was dead code until recently

`require 'custom.plugins'` (`init.lua:1156`) was commented out. Anything in that
directory did nothing at all. If a custom plugin file ever "isn't loading", check that
line first — it's the auto-loader for every `lua/custom/plugins/*.lua`.

---

# Appendix E: Changelog

Condensed from the `CHANGELOG` block at `init.lua:1159-1205`, which stays the source of
truth.

**2026-08-27 — autosave stops firing autocmds.**
The per-second background write now uses `noautocmd`, so it no longer triggers
`BufWrite` autocmds every second — conform's format-on-save, fidget notifications, and
the rest. A manual `:w` still runs them.

**2026-08-28 — image and SVG preview.**
Added image.nvim for inline rendering and telescope-media-files for a preview picker
(`<leader>fm`). *This entry turned out to be wrong; see below.*

**2026-09-01 — markdown stack, and fixing the image support that never worked.**
The 2026-08-28 image support rendered nothing for four days. Four separate causes:

1. image.nvim's processor needs **ImageMagick**, which wasn't installed.
2. `backend` was hardcoded to `'kitty'`. iTerm2 doesn't speak that protocol — now
   detected from `TERM_PROGRAM` / `KITTY_WINDOW_ID`, overridable with
   `$IMAGE_NVIM_BACKEND` (7.5).
3. `integrations.nvim_tree` **does not exist** in current image.nvim and was silently
   ignored. Viewing images from the tree works via `hijack_file_patterns` instead.
4. Sizing: `max_width` / `max_height` are absolute caps in columns and rows applied
   *after* the percentage caps, so `max_height = 12` overrode everything and shrank every
   image. Both dropped; now 100% window width, 80% height. And
   `max_width_window_percentage = math.huge` passed the plugin's `type(x) == 'number'`
   guard, then computed `math.floor(inf)`.

Also that day: added `<leader>ti` / `:ImageToggle`, since images are painted over the
window and can't reflow around text. Discovered `require 'custom.plugins'` had been
commented out all along, making the whole directory dead code — enabled it (D.6). Added
`lua/custom/plugins/markdown.lua`: render-markdown (`<leader>tm`), the glow float
(`:Glow`, `<leader>mp`), the `:Telescope markdown` picker (`<leader>sm` / `sM` / `sG`,
with `<C-g>` in-picker), and the `sel` visual operator (3.4). Installed poppler so
telescope-media-files' `pdf` filetype — listed since 08-28 but needing `pdftoppm` —
actually previews.

---

*Written 2026-09-01. When this file and `init.lua` disagree, `init.lua` is right — go fix
this one.*
