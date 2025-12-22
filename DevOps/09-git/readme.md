# Git Version Control Mastery 🔥

Complete guide to Git for version control and collaboration.

---

## Initialize Repository

```bash
# Initialize new repo in current directory
git init

# Create in specific directory
git init <directory>

# Clone existing repository
git clone <url>

# Clone specific branch
git clone --branch <name> <url>
```

---

## Staging & Committing

```bash
# Add specific file
git add <file>

# Add all changes
git add .

# Show repository status
git status

# View unstaged changes
git diff

# View staged changes (ready to commit)
git diff --staged

# Difference from last commit
git diff HEAD

# Difference between two commits
git diff <commit1> <commit2>
```

### Commit Changes

```bash
# Commit with message
git commit -m "message"

# Commit all tracked changes
git commit -a

# Add notes to commit
git notes add
```

---

## Undoing Changes

### Discard Changes

```bash
# Discard changes in working directory
git restore <file>

# Discard all changes in working directory
git checkout -- .
```

### Reset Commits

```bash
# Soft reset (keeps changes in staging)
git reset <commit>

# Keep changes in staging
git reset --soft <commit>

# Discard all changes completely
git reset --hard <commit>
```

### Revert Commits

```bash
# Create new commit that undoes changes
git revert <commit>

# Undo without creating commit
git revert --no-commit <commit>
```

---

## File Management

```bash
# Remove file from repo
git rm <file>

# Move/rename file
git mv <old> <new>
```

---

## Branching & Merging

### Create & Switch Branches

```bash
# List local branches
git branch

# Create new branch
git branch <branch-name>

# Delete branch
git branch -d <branch>

# List all branches (local + remote)
git branch -a

# List remote branches only
git branch -r

# Switch to branch
git checkout <branch>

# Create and switch to branch
git checkout -b <branch>
```

### Merge Branches

```bash
# Merge branch into current branch
git merge <branch>

# Merge with commit message
git merge --no-ff <branch>
```

---

## History & Logs

```bash
# Show commit history
git log

# Show specific branch history
git log <branch>

# Show history including renames
git log --follow <file>

# Show all branches
git log --all

# One-line history
git log --oneline

# Show graph of branches
git log --graph --oneline --all
```

---

## Stashing

Save work in progress without committing.

```bash
# Stash current changes
git stash

# List all stashes
git stash list

# Apply latest stash and remove it
git stash pop

# Apply stash without removing
git stash apply

# Drop latest stash
git stash drop
```

---

## Tags

```bash
# List all tags
git tag

# Create lightweight tag
git tag <tag-name>

# Tag specific commit
git tag <tag-name> <commit>

# Create annotated tag (with message)
git tag -a <tag> -m "msg"

# Delete tag
git tag -d <tag>
```

---

## Remote Repositories

### Fetch & Pull

```bash
# Fetch all changes
git fetch

# Fetch from specific remote
git fetch <remote>

# Remove deleted branches locally
git fetch --prune

# Fetch and merge
git pull

# From specific remote
git pull <remote>

# Fetch and rebase
git pull --rebase
```

### Push

```bash
# Push to default remote
git push

# To specific remote
git push <remote>

# Specific branch
git push <remote> <branch>

# All branches
git push --all

# With tags
git push --tags
```

### Manage Remotes

```bash
# List remotes
git remote

# Show remote details
git remote -v

# Add new remote
git remote add <name> <url>

# Remove remote
git remote remove <name>

# Rename remote
git remote rename <old> <new>
```

---

## Show Details

```bash
# Show latest commit details
git show

# Show specific commit details
git show <commit>

# Show file at specific commit
git show <commit>:<path>
```

---

## Commit Message Conventions

```bash
git commit -m "feat: add new feature"       # New feature
git commit -m "fix: resolve bug"            # Bug fix
git commit -m "docs: update readme"         # Documentation
git commit -m "style: format code"          # Code style
git commit -m "refactor: improve code"      # Refactoring
git commit -m "test: add unit tests"        # Tests
git commit -m "chore: update deps"          # Maintenance
git commit -m "perf: optimize performance"  # Performance
git commit -m "ci: update CI/CD"            # CI/CD
git commit -m "build: update build"         # Build process
git commit -m "revert: undo commit"         # Revert previous
```

---

## Common Workflows

### Feature Branch Workflow

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "feat: implement feature"

# 3. Push to remote
git push -u origin feature/new-feature

# 4. Create Pull Request on GitHub/GitLab

# 5. After approval, merge
git checkout main
git pull origin main
git merge feature/new-feature
git push origin main

# 6. Delete feature branch
git branch -d feature/new-feature
```

### Sync with Upstream

```bash
# Add upstream remote
git remote add upstream <upstream-url>

# Fetch upstream changes
git fetch upstream

# Merge upstream into local
git merge upstream/main

# Or rebase (cleaner history)
git rebase upstream/main
```

---

**Last Updated:** December 22, 2025
