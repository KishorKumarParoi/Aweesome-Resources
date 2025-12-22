# T-mux (Terminal Multiplexer) 🔀

Master terminal multiplexing for efficient workflow management.

---

## What is T-mux?

T-mux allows you to create multiple **sessions**, **windows**, and **panes** within a single terminal, enabling complex workflows and persistent terminal sessions.

---

## Basic Setup

```bash
# Start new session
tmux

# Create alias for faster access
alias t=tmux

# Use alias
t
```

---

## Session Management

### Create & Attach Sessions

```bash
# List all active sessions
tmux ls

# Create new session with name
tmux new -s aws

# Attach to specific session
tmux a -t 0              # Attach to session 0
tmux a -t aws            # Attach to session 'aws'

# Detach from current session
Ctrl+b d
```

### Delete Sessions

```bash
# Kill specific session
tmux kill-session -t aws

# Kill all sessions
tmux kill-server
```

---

## Pane Management (Split Windows)

Create multiple panes within a window for side-by-side work.

```bash
# Split vertically (side by side)
Ctrl+b %

# Split horizontally (top/bottom)
Ctrl+b "

# Navigate between panes
Ctrl+b + arrow key

# Show pane index
Ctrl+b q

# Kill pane
Ctrl+b x

# Toggle maximize pane
Ctrl+b z

# Resize panes
Ctrl+b {    # Move left
Ctrl+b }    # Move right
```

---

## Window Management

Organize work into multiple windows within a session.

```bash
# Create new window
Ctrl+b c

# List windows
Ctrl+b w

# Rename window
Ctrl+b ,

# Next window
Ctrl+b n

# Previous window
Ctrl+b p

# Jump to specific window
Ctrl+b [number]

# Kill window
Ctrl+b &
```

---

## Practical Workflow Example

```bash
# Create session
tmux new -s dev

# Split into multiple panes
# Ctrl+b %  - Split for code editor
# Ctrl+b "  - Split for terminal

# Navigate windows
# Ctrl+b c  - New window for server
# Ctrl+b c  - New window for tests

# Detach
# Ctrl+b d

# Later, reattach
tmux a -t dev
```

---

## Advanced Commands

### Session Layout

```bash
# Show session info
tmux info

# List all panes in session
tmux list-panes -t dev -s

# Capture pane content
tmux capture-pane -t dev -p
```

### Configuration

Create `~/.tmux.conf` for custom settings:

```bash
# Set prefix to Ctrl+a (instead of Ctrl+b)
set -g prefix C-a

# Mouse support
set -g mouse on

# Numbering from 1 (instead of 0)
set -g base-index 1

# Vi mode
setw -g mode-keys vi
```

Reload config:
```bash
tmux source ~/.tmux.conf
```

---

## Quick Reference Cheatsheet

| Action | Command |
|--------|---------|
| **New Session** | `tmux new -s name` |
| **List Sessions** | `tmux ls` |
| **Attach Session** | `tmux a -t name` |
| **Detach** | `Ctrl+b d` |
| **Kill Session** | `tmux kill-session -t name` |
| **Split Vertical** | `Ctrl+b %` |
| **Split Horizontal** | `Ctrl+b "` |
| **Navigate Pane** | `Ctrl+b arrow` |
| **New Window** | `Ctrl+b c` |
| **Next Window** | `Ctrl+b n` |
| **Previous Window** | `Ctrl+b p` |

---

**Last Updated:** December 22, 2025
