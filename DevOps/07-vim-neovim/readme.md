# Vim & NeoVim Text Editors ✏️

Master Vim and NeoVim for efficient text editing in the terminal.

---

## Vim Editor

### Insert & Edit Modes

```
i   - Insert before cursor
a   - Insert after cursor
o   - Insert on next line
O   - Insert on previous line

Shift+i - Insert at line start
Shift+a - Insert at line end
```

### Navigation & Search

```
/keyword   - Search forward (press 'n' for next, 'N' for previous)
?keyword   - Search backward (press 'n' for previous, 'N' for next)

gg  - Go to top of file
G   - Go to bottom of file
0   - Go to line start
$   - Go to line end
:3  - Go to line 3
```

### Edit & Delete

```
x       - Delete single character
dd      - Delete entire line
15dd    - Delete 15 lines
r       - Replace character in Replace mode

%s/old/new/g  - Replace all occurrences
```

### Copy & Paste

```
y   - Yank (copy)
yy  - Yank entire line
v   - Visual selection (character)
V   - Visual selection (line)
p   - Paste after
P   - Paste before
```

### Undo & Redo

```
u       - Undo
Ctrl+r  - Redo
```

### Settings

```
:set nu      - Show line numbers
:set nonu    - Hide line numbers
:set syntax on  - Enable syntax highlighting

:w    - Save
:q    - Quit
:q!   - Quit without saving
:wq!  - Save and quit
:e!   - Revert all changes
```

---

## NeoVim (Modern Vim)

### Basic Navigation

```
h - Left     j - Down    k - Up     l - Right
gg - Top of file
G - Bottom of file
0 - Start of line
$ - End of line
e - Word by word
```

### Leader Key (Spacebar)

```
<space>ff - Find files
<space>sg - Search grep (across codebase)
<space>ft - Open terminal
<space>E - Toggle sidebar
<space>- - Split horizontally
<space>| - Split vertically
```

### Mode Switching

```
i - Insert mode
Esc - Exit to normal mode
v - Visual mode (character select)
V - Visual mode (line select)
```

### LSP (Language Server Protocol)

```
gd - Go to definition
K - Hover documentation
<leader>cr - Smart rename
<leader>cf - Format code
<leader>ca - Code actions
<leader>cR - Remove unused imports
<leader>co - Organize imports
```

### Window Management

```
<leader>- - Split horizontally
<leader>| - Split vertically
Ctrl+h/j/k/l - Navigate windows

<leader>ul - Toggle line numbers
```

### Find & Replace

```
/className - Find word
Esc then 'n' - Go to next match

:%s/toReplace/replace/g - Find and replace (local)
```

### Buffer & File Management

```
% - Create new file in sidebar
d - Create new directory in sidebar
m - Move file
x or d (sidebar) - Delete file
:Explore - File explorer
```

### NeoVim Cheatsheet Summary

```
1. Open sidebar → a(add), d(delete), m(move)
2. Find file → <leader>ff
3. Search codebase → <leader>sg
4. Split windows → <leader>-, <leader>|
5. Navigate windows → Ctrl+(h/j/k/l)
6. Go to definition → gd
7. Code actions → <leader>ca
8. Format code → <leader>cf
9. Open terminal → <leader>ft
10. Line numbers → <leader>ul
```

---

## Vim vs NeoVim

| Feature | Vim | NeoVim |
|---------|-----|--------|
| **Configuration** | vimrc (VimL) | init.lua (Lua) |
| **Plugins** | Vim plugins | Modern plugin ecosystem |
| **Performance** | Stable | Fast, async-first |
| **Development** | Slower updates | Active development |
| **Learning Curve** | Moderate | Slightly steeper |

---

**Last Updated:** December 22, 2025
