# Keymap reference

Generated from the live config by `scripts/gen-keymaps.lua` — do not edit by hand.
Regenerate with:

```sh
nvim --headless -u init.lua init.lua -c "luafile scripts/gen-keymaps.lua" -c "qa!"
```

`<leader>` is <kbd>Space</kbd>. Maps marked *(buf)* are buffer-local and only
appear when something has attached to the buffer (an LSP, gitsigns).

For a searchable version inside nvim, use `<leader>sk`.

## Git: blame

| Key | Mode | Action |
|---|---|---|
| `<leader>gB` | Normal | [G]it [B]lame full file (split) *(buf)* |
| `<leader>gb` | Normal | [G]it [b]lame line (popup) *(buf)* |
| `<leader>tb` | Normal | [T]oggle git [b]lame line *(buf)* |

## Git: hunks

| Key | Mode | Action |
|---|---|---|
| `<leader>gs` | Normal | [G]it [S]tatus |
| `<leader>hD` | Normal | Git [D]iff against last commit *(buf)* |
| `<leader>hQ` | Normal | Git hunks -> [Q]uickfix (all files) *(buf)* |
| `<leader>hR` | Normal | Git [R]eset buffer *(buf)* |
| `<leader>hS` | Normal | Git [S]tage buffer *(buf)* |
| `<leader>hd` | Normal | Git [d]iff against index *(buf)* |
| `<leader>hi` | Normal | Git preview hunk [i]nline *(buf)* |
| `<leader>hp` | Normal | [H]unk [P]review *(buf)* |
| `<leader>hq` | Normal | Git hunks -> [q]uickfix (this file) *(buf)* |
| `<leader>hr` | Normal | Git [r]eset hunk *(buf)* |
| `<leader>hr` | Select | Git [r]eset selection *(buf)* |
| `<leader>hr` | Visual | Git [r]eset selection *(buf)* |
| `<leader>hr` | Visual block | Git [r]eset selection *(buf)* |
| `<leader>hs` | Normal | Git [s]tage hunk *(buf)* |
| `<leader>hs` | Select | Git [s]tage selection *(buf)* |
| `<leader>hs` | Visual | Git [s]tage selection *(buf)* |
| `<leader>hs` | Visual block | Git [s]tage selection *(buf)* |
| `<leader>tw` | Normal | [T]oggle git intra-line [w]ord diff *(buf)* |
| `[c` | Normal | Previous git hunk *(buf)* |
| `]c` | Normal | Next git hunk *(buf)* |
| `ih` | Operator-pending | [i]nner git [h]unk *(buf)* |
| `ih` | Visual | [i]nner git [h]unk *(buf)* |
| `ih` | Visual block | [i]nner git [h]unk *(buf)* |

## Search (Telescope)

| Key | Mode | Action |
|---|---|---|
| `<leader>s.` | Normal | [S]earch Recent Files ("." for repeat) |
| `<leader>s/` | Normal | [S]earch [/] in Open Files |
| `<leader>sF` | Normal | [S]earch [F]iles (ignored) |
| `<leader>sG` | Normal | [S]earch [G]rep in markdown |
| `<leader>sM` | Normal | [S]earch [M]arkdown files (all) |
| `<leader>sa` | Normal | [S]earch [A]ll files (hidden + ignored, case-insensitive) |
| `<leader>sc` | Normal | [S]earch [C]ommands |
| `<leader>sd` | Normal | [S]earch [D]iagnostics |
| `<leader>sf` | Normal | [S]earch [F]iles |
| `<leader>sg` | Normal | [S]earch by [G]rep |
| `<leader>sh` | Normal | [S]earch [H]elp |
| `<leader>sk` | Normal | [S]earch [K]eymaps |
| `<leader>sm` | Normal | [S]earch [M]arkdown files |
| `<leader>sn` | Normal | [S]earch [N]eovim files |
| `<leader>sr` | Normal | [S]earch [R]esume |
| `<leader>ss` | Normal | [S]earch [S]elect Telescope |
| `<leader>sw` | Normal | [S]earch current [W]ord |
| `<leader>sw` | Select | [S]earch current [W]ord |
| `<leader>sw` | Visual | [S]earch current [W]ord |
| `<leader>sw` | Visual block | [S]earch current [W]ord |

## LSP

| Key | Mode | Action |
|---|---|---|
| `<leader>th` | Normal | LSP: [T]oggle Inlay [H]ints *(buf)* |
| `<C-S>` | Insert | vim.lsp.buf.signature_help() |
| `<C-S>` | Select | vim.lsp.buf.signature_help() |
| `<C-S>` | Visual | vim.lsp.buf.signature_help() |
| `K` | Normal | vim.lsp.buf.hover() *(buf)* |
| `grD` | Normal | LSP: [G]oto [D]eclaration *(buf)* |
| `gra` | Normal | LSP: [G]oto Code [A]ction *(buf)* |
| `gra` | Visual | LSP: [G]oto Code [A]ction *(buf)* |
| `gra` | Visual block | LSP: [G]oto Code [A]ction *(buf)* |
| `grn` | Normal | LSP: [R]e[n]ame *(buf)* |
| `grx` | Normal | vim.lsp.codelens.run() |

## Debug (DAP)

| Key | Mode | Action |
|---|---|---|
| `<leader>db` | Normal | [D]ebug Toggle [B]reakpoint |
| `<leader>dr` | Normal | [D]ebug Toggle [R]epl |
| `<leader>dt` | Normal | [D]ebug [T]est method under cursor |
| `<leader>du` | Normal | [D]ebug Toggle [U]I |
| `<F10>` | Normal | Debug: Step Over |
| `<F11>` | Normal | Debug: Step Into |
| `<F12>` | Normal | Debug: Step Out |
| `<F5>` | Normal | Debug: Start/Continue |

## Buffers & windows

| Key | Mode | Action |
|---|---|---|
| `<leader>bd` | Normal | [B]uffer [D]elete |
| `<leader>bo` | Normal | [B]uffer close [O]thers |
| `<C-Down>` | Normal | Shrink window height |
| `<C-H>` | Normal | Move focus to the left window |
| `<C-J>` | Normal | Move focus to the lower window |
| `<C-K>` | Normal | Move focus to the upper window |
| `<C-L>` | Normal | Move focus to the right window |
| `<C-Left>` | Normal | Shrink window width |
| `<C-Right>` | Normal | Grow window width |
| `<C-Up>` | Normal | Grow window height |

## Diagnostics

| Key | Mode | Action |
|---|---|---|
| `<leader>q` | Normal | Open diagnostic [Q]uickfix list |
| `<C-W><C-D>` | Normal | Show diagnostics under the cursor |
| `<C-W>d` | Normal | Show diagnostics under the cursor |
| `[D` | Normal | Jump to the first diagnostic in the current buffer |
| `[d` | Normal | Jump to the previous diagnostic in the current buffer |
| `]D` | Normal | Jump to the last diagnostic in the current buffer |
| `]d` | Normal | Jump to the next diagnostic in the current buffer |

## Surround & text objects

| Key | Mode | Action |
|---|---|---|
| `[N` | Visual | Select previous sibling node |
| `[N` | Visual block | Select previous sibling node |
| `[n` | Visual | Select previous node |
| `[n` | Visual block | Select previous node |
| `]N` | Visual | Select next sibling node |
| `]N` | Visual block | Select next sibling node |
| `]n` | Visual | Select next node |
| `]n` | Visual block | Select next node |
| `a` | Operator-pending | Around textobject |
| `a` | Visual | Around textobject |
| `a` | Visual block | Around textobject |
| `aa` | Operator-pending | Around next textobject |
| `aa` | Visual | Around next textobject |
| `aa` | Visual block | Around next textobject |
| `al` | Operator-pending | Around last textobject |
| `al` | Visual | Around last textobject |
| `al` | Visual block | Around last textobject |
| `an` | Operator-pending | Select parent (outer) node |
| `an` | Visual | Select parent (outer) node |
| `an` | Visual block | Select parent (outer) node |
| `gc` | Operator-pending | Comment textobject |
| `i` | Operator-pending | Inside textobject |
| `i` | Visual | Inside textobject |
| `i` | Visual block | Inside textobject |
| `ii` | Operator-pending | Inside next textobject |
| `ii` | Visual | Inside next textobject |
| `ii` | Visual block | Inside next textobject |
| `il` | Operator-pending | Inside last textobject |
| `il` | Visual | Inside last textobject |
| `il` | Visual block | Inside last textobject |
| `in` | Operator-pending | Select child (inner) node |
| `in` | Visual | Select child (inner) node |
| `in` | Visual block | Select child (inner) node |
| `sF` | Normal | Find left surrounding |
| `sF` | Operator-pending | Find left surrounding |
| `sF` | Visual | Find left surrounding |
| `sF` | Visual block | Find left surrounding |
| `sFl` | Normal | Find previous left surrounding |
| `sFl` | Operator-pending | Find previous left surrounding |
| `sFl` | Visual | Find previous left surrounding |
| `sFl` | Visual block | Find previous left surrounding |
| `sFn` | Normal | Find next left surrounding |
| `sFn` | Operator-pending | Find next left surrounding |
| `sFn` | Visual | Find next left surrounding |
| `sFn` | Visual block | Find next left surrounding |
| `sa` | Normal | Add surrounding |
| `sa` | Visual | Add surrounding to selection |
| `sa` | Visual block | Add surrounding to selection |
| `sd` | Normal | Delete surrounding |
| `sdl` | Normal | Delete previous surrounding |
| `sdn` | Normal | Delete next surrounding |
| `sf` | Normal | Find right surrounding |
| `sf` | Operator-pending | Find right surrounding |
| `sf` | Visual | Find right surrounding |
| `sf` | Visual block | Find right surrounding |
| `sfl` | Normal | Find previous right surrounding |
| `sfl` | Operator-pending | Find previous right surrounding |
| `sfl` | Visual | Find previous right surrounding |
| `sfl` | Visual block | Find previous right surrounding |
| `sfn` | Normal | Find next right surrounding |
| `sfn` | Operator-pending | Find next right surrounding |
| `sfn` | Visual | Find next right surrounding |
| `sfn` | Visual block | Find next right surrounding |
| `sh` | Normal | Highlight surrounding |
| `shl` | Normal | Highlight previous surrounding |
| `shn` | Normal | Highlight next surrounding |
| `sr` | Normal | Replace surrounding |
| `srl` | Normal | Replace previous surrounding |
| `srn` | Normal | Replace next surrounding |

## Toggles

| Key | Mode | Action |
|---|---|---|
| `<leader>e` | Normal | Toggle file tree |
| `<leader>ti` | Normal | [T]oggle [I]mages |
| `<leader>tm` | Normal | [T]oggle [M]arkdown rendering |
| `gc` | Normal | Toggle comment |
| `gc` | Visual | Toggle comment |
| `gc` | Visual block | Toggle comment |
| `gcc` | Normal | Toggle comment line |

## Editing

| Key | Mode | Action |
|---|---|---|
| `<leader> ` | Normal | [ ] Find existing buffers |
| `<leader>/` | Normal | [/] Fuzzily search in current buffer |
| `<leader>Do` | Normal | [D]atabase UI [O]pen/close |
| `<leader>f` | Normal | [F]ormat buffer |
| `<leader>f` | Select | [F]ormat buffer |
| `<leader>f` | Visual | [F]ormat buffer |
| `<leader>f` | Visual block | [F]ormat buffer |
| `<leader>fm` | Normal | [F]ind [M]edia files (preview) |
| `<leader>mp` | Normal | [M]arkdown [P]review (glow) |
| `<leader>p` | Visual | [P]aste without yanking selection |
| `<leader>p` | Visual block | [P]aste without yanking selection |
| `<C-E>` | Command | blink.cmp: Cancel |
| `<C-N>` | Command | blink.cmp: Select Next |
| `<C-P>` | Command | blink.cmp: Select Prev |
| `<C-Space>` | Command | blink.cmp: Show |
| `<C-Y>` | Command | blink.cmp: Select And Accept |
| `<C-]>` | Insert | [copilot] dismiss suggestion *(buf)* |
| `<End>` | Command | blink.cmp: Hide |
| `<Esc><Esc>` | Terminal | Exit terminal mode |
| `<Left>` | Command | blink.cmp: Select Prev |
| `<M-[>` | Insert | [copilot] prev suggestion *(buf)* |
| `<M-]>` | Insert | [copilot] next suggestion *(buf)* |
| `<M-l>` | Insert | [copilot] accept suggestion *(buf)* |
| `<Right>` | Command | blink.cmp: Select Next |
| `<S-Tab>` | Command | blink.cmp: <Custom Fn>, Select Prev |
| `<S-Tab>` | Insert | vim.snippet.jump if active, otherwise <S-Tab> |
| `<S-Tab>` | Select | vim.snippet.jump if active, otherwise <S-Tab> |
| `<S-Tab>` | Visual | vim.snippet.jump if active, otherwise <S-Tab> |
| `<Tab>` | Command | blink.cmp: Show And Insert Or Accept Single, Select Next |
| `<Tab>` | Insert | vim.snippet.jump if active, otherwise <Tab> |
| `<Tab>` | Select | vim.snippet.jump if active, otherwise <Tab> |
| `<Tab>` | Visual | vim.snippet.jump if active, otherwise <Tab> |
| `<lt>` | Select | Indent left, keep selection |
| `<lt>` | Visual | Indent left, keep selection |
| `<lt>` | Visual block | Indent left, keep selection |
| `>` | Select | Indent right, keep selection |
| `>` | Visual | Indent right, keep selection |
| `>` | Visual block | Indent right, keep selection |
| `J` | Select | Move selection down |
| `J` | Visual | Move selection down |
| `J` | Visual block | Move selection down |
| `K` | Select | Move selection up |
| `K` | Visual | Move selection up |
| `K` | Visual block | Move selection up |
| `N` | Normal | Prev search result, centred |
| `[ ` | Normal | Add empty line above cursor |
| `[<C-L>` | Normal | :lpfile |
| `[<C-Q>` | Normal | :cpfile |
| `[<C-T>` | Normal | :ptprevious |
| `[A` | Normal | :rewind |
| `[B` | Normal | :brewind |
| `[L` | Normal | :lrewind |
| `[Q` | Normal | :crewind |
| `[T` | Normal | :trewind |
| `[a` | Normal | :previous |
| `[b` | Normal | :bprevious |
| `[l` | Normal | :lprevious |
| `[q` | Normal | :cprevious |
| `[t` | Normal | :tprevious |
| `] ` | Normal | Add empty line below cursor |
| `]<C-L>` | Normal | :lnfile |
| `]<C-Q>` | Normal | :cnfile |
| `]<C-T>` | Normal | :ptnext |
| `]A` | Normal | :last |
| `]B` | Normal | :blast |
| `]L` | Normal | :llast |
| `]Q` | Normal | :clast |
| `]T` | Normal | :tlast |
| `]a` | Normal | :next |
| `]b` | Normal | :bnext |
| `]l` | Normal | :lnext |
| `]q` | Normal | :cnext |
| `]t` | Normal | :tnext |
| `gO` | Normal | Open Document Symbols *(buf)* |
| `gW` | Normal | Open Workspace Symbols *(buf)* |
| `g[` | Normal | Move to left "around" |
| `g[` | Operator-pending | Move to left "around" |
| `g[` | Visual | Move to left "around" |
| `g[` | Visual block | Move to left "around" |
| `g]` | Normal | Move to right "around" |
| `g]` | Operator-pending | Move to right "around" |
| `g]` | Visual | Move to right "around" |
| `g]` | Visual block | Move to right "around" |
| `grd` | Normal | [G]oto [D]efinition *(buf)* |
| `gri` | Normal | [G]oto [I]mplementation *(buf)* |
| `grr` | Normal | [G]oto [R]eferences *(buf)* |
| `grt` | Normal | [G]oto [T]ype Definition *(buf)* |
| `gx` | Normal | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `gx` | Visual | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `gx` | Visual block | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `n` | Normal | Next search result, centred |
| `sel` | Visual | [S]urround [E]very [L]ine |
| `sel` | Visual block | [S]urround [E]very [L]ine |

