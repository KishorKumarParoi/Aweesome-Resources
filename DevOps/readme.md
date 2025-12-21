# DevOps Learning Resources 🚀

## Table of Contents
1. [E-commerce Project](#e-commerce-project)
2. [Kode Kloud](#kode-kloud)
3. [Networking](#networking)
4. [AWS CLI](#aws-cli)
5. [Linux & OS Fundamentals](#why-linux-and-how-os-works)
6. [Linux Commands](#linux-commands)
7. [Vim & NeoVim](#vim)
8. [Terminal Multiplexer (T-mux)](#t-mux)
9. [Git](#git)
10. [AWS Shell Scripting](#aws-shell-scripting-project)
11. [AWS Services](#aws-services)
12. [Configuration Management (Ansible)](#configuration-management-aka-ansible)
13. [Databases](#databases)
14. [Docker](#docker)
15. [Kubernetes](#kubernetes)
16. [Terraform](#terraform)
17. [Ultimate DevOps Project](#ultimate-devops-project)

---

## E-commerce Project

### EC2 SSH Connection
```bash
# Connect to EC2 instance
ssh -i devOps-demo.pem ubuntu@52.204.118.38

# Fix permission on PEM file
chmod 600 devOps-demo.pem
```

### Docker Engine Installation
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Test Docker Installation
```bash
sudo docker run hello-world
```

### Add Ubuntu User to Docker Group
```bash
# Avoid using 'sudo' with docker commands
sudo usermod -aG docker ubuntu

# Logout and login again for changes to take effect
```

### Kubectl Installation
```bash
# 1. Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 2. Validate binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# 3. Check kubectl
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# 4. Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 5. Verify installation (client version)
kubectl version --client

# 6. Detailed version info
kubectl version --client --output=yaml

# 7. Check both server and client versions
kubectl version
```

### Terraform Installation
```bash
# 1. Update and install dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# 2. Add GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# 3. Verify GPG key
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# 4. Add terraform repository to apt
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 5. Update and install terraform
sudo apt update
sudo apt-get install terraform

# 6. Verify installation
terraform -help plan

# 7. Setup bash autocomplete
touch ~/.bashrc
terraform -install-autocomplete
```

### Docker Compose Help
```bash
docker compose -h
```

### Resize EC2 Volume

**Step 1: Check Current Disk Usage**
```bash
df -h
lsblk
```

**Step 2: Increase Volume Size**
- Go to AWS EC2 Console → Storage → Volumes
- Select your volume → Modify
- Increase size and monitor "Volume state"

**Step 3: Verify Volume Increase**
```bash
lsblk
# xvda should show increased size, but xvda1 partition unchanged
```

**Step 4: Install cloud-guest-utils (if needed)**
```bash
sudo apt install cloud-guest-utils
```

**Step 5: Grow the Partition**
```bash
sudo growpart /dev/xvda 1
# Output: CHANGED: partition=1 start=2099200 old: size=14677983 end=16777182 new: size=31455199 end=33554398

# Verify
lsblk
# xvda1 should now show 15G (or your new size)
```

**Step 6: Update File System**
```bash
# For ext4
sudo resize2fs /dev/xvda1

# Output:
# resize2fs 1.47.0 (5-Feb-2023)
# Filesystem at /dev/xvda1 is mounted on /; on-online resizing required
# old_desc_blocks = 1, new_desc_blocks = 2
# The filesystem on /dev/xvda1 is now 3931899 (4k) blocks long.

# Verify final size
df -h
lsblk
```

**Step 7: Verify Port Access**
```bash
# Backend server should run on port 3001 or 8080
# Make sure Security Group allows port 22 (SSH) and your app port
curl http://3.87.86.145:8080
```

---

## Kode Kloud

### Important System Commands
- `12 factor app` - Application design principles
- `dmesg` - Display kernel messages
- `uname -r` - Show kernel release
- `lspci` - List PCI devices
- `udevadm monitor` - Monitor device events
- `lsmem` - Display memory info
- `lshw` - List hardware
- `k` - Alias for kubectl

---

## Networking

### TCP Packet Capture
```bash
# Capture packets from/to specific IP
sudo tcpdump -vni en0 src 216.58.200.174 or dst 216.58.200.174

# Capture ICMP packets
sudo tcpdump -vni icmp

# Capture all traffic on interface
sudo tcpdump -vni en0
```

### Attach External Volume to EC2

```bash
# 1. Format the volume
sudo mkfs -t xfs /dev/xvdf

# 2. Check file system
sudo file -s /dev/xvdf

# 3. Mount volume
sudo mount /dev/xvdf mountFolder/

# 4. Check mounted volumes
df -k

# 5. Resize volume
# For ext4:
resize2fs /dev/xvdf

# For xfs:
sudo xfs_growfs /home/ubuntu/mountFolder
```

---

## AWS CLI

### Initial SSH Connection (Without Key)
```bash
ssh ubuntu@34.239.181.190
# Error: Permission denied (publickey)
```

### SSH Connection With PEM Key
```bash
ssh -i test.pem ubuntu@34.239.181.190
# Error: WARNING: UNPROTECTED PRIVATE KEY FILE!
# Permissions 0644 for 'test.pem' are too open
```

### Fix PEM File Permissions
```bash
chmod 600 test.pem

# Now retry connection
ssh -i test.pem ubuntu@34.239.181.190
# Success! ✅
```

---

## Why Linux and How OS Works

### Linux Advantages
- **Free** - No licensing costs
- **Fast** - Lightweight and efficient
- **Open Source** - Community-driven development
- **Secure** - Robust security features

### OS Architecture

```
┌─────────────────────────┐
│   Applications/Users    │
├─────────────────────────┤
│   System Libraries      │
├─────────────────────────┤
│  Shell & Utilities      │
├─────────────────────────┤
│   KERNEL (Heart of OS)  │
├─────────────────────────┤
│   Hardware/CPU/Memory   │
└─────────────────────────┘
```

**Key Point:** The **Kernel** is the heart of the OS
- Manages all resources
- Handles memory, processes, files, and devices
- Acts as intermediary between hardware and software

---

## Linux Commands

### File Operations
```bash
# List with human-readable sizes
ls -lh

# More vs Less
more file.txt    # Print to terminal
less file.txt    # Open in editor

# Sort and unique
sort data.txt | uniq

# Split files
split -l 3 data.txt

# Search patterns
egrep "dolor|Dolan" test.json

# Wildcard patterns
ls *.sh
ls x*
touch file{1..10}

# Shuffle content
shuf test.json

# Count lines
wc -l test.json

# Compare files
cmp test.json Linux_Command.pdf
diff -u file1 file2

# Find files
find ./folder/ -name test.json
find . -name xaa
find ./Projects/ -name test.json
mdfind "kind:pdf AND Linux"  # macOS
locate test.json             # Linux
updatedb                      # Update locate database
```

### Utilities
```bash
# Calculator
bc

# Calendar
cal
cal 100

# Record terminal session
script
# (press Ctrl+D to stop)

# Create alias
alias l="ls -ltr"
```

### Compression
```bash
# Gzip
gzip -k test.json           # Keep original
gzip -d test.json.gz        # Decompress

# Tar (tar+gzip)
tar -czf compress_folder.tar.gz folder/
tar -xzf compress_folder.tar.gz

# Zip
zip files.zip file1 file2
unzip files.zip
unzip -l files.zip          # List contents
```

### Network & Download
```bash
# HTTP request
curl http://numberapi.com/random

# Download file
wget -o kkp.txt url_link    # Linux only
curl url -o output.txt      # macOS alternative
```

### Package Management
```bash
# RedHat/CentOS
sudo yum install nginx
rpm -qa | grep sql

# macOS
brew list | grep nginx

# Debian/Ubuntu
dnf list installed
```

### Text Processing
```bash
# AWK - Powerful field/record processing
awk -F, '{print $2}' test.csv         # Print 2nd column
awk -F, '{print $NF}' test.csv        # Print last column
awk -F, '{print $NF$2$3}' test.csv    # Combine columns

# CUT - Extract columns
cut -c3-10 test.csv                   # Characters 3-10

# SED - Stream editor
sed -n '5p' test.csv                  # Print line 5
sed -n 's/gmail/kkpmail/g' test.csv   # Replace globally

# TR - Translate/delete characters
tr -d '10' < test.csv                 # Delete 1,0
tr [:upper:] [:lower:] < test.csv     # Convert to lowercase
```

### File Size & Viewing
```bash
# Truncate file to 50MB
truncate -s 50M file.txt

# Fold into single characters
cat test.csv | fold -w1
```

### File Transfer
```bash
# Secure copy to remote
scp file user@hostname:/tmp/
```

### Permissions & Ownership
```bash
# Change owner
chown kkp file.txt

# Change group
chgrp kkp file.txt
```

### Process Management
```bash
# Find process by name
pgrep chron
```

### Environment Variables
```bash
# View environment variables
printenv | grep TESTVAR

# Source bashrc for persistent changes
source ~/.bashrc
```

---

## Vim

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

## NeoVim

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

### Cheatsheet Summary
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

## T-mux (Terminal Multiplexer)

T-mux allows you to create multiple **sessions**, **windows**, and **panes** in a single terminal.

### Basic Setup
```bash
tmux                    # Start new session
alias t=tmux            # Create alias
t                       # Use alias
```

### Session Management
```bash
Ctrl+b d        - Detach from session
tmux ls         - List all sessions
tmux a -t 0     - Attach to session 0
tmux new -s aws - Create new session named 'aws'
tmux kill-session -t aws - Kill session
```

### Pane Management (Split Windows)
```bash
Ctrl+b %  - Split vertically
Ctrl+b "  - Split horizontally
Ctrl+b + arrow key - Navigate between panes
Ctrl+b q  - Show pane index
Ctrl+b x  - Kill pane
```

### Window Management
```bash
Ctrl+b c           - Create new window
Ctrl+b w           - List windows
Ctrl+b ,           - Rename window
Ctrl+b n           - Next window
Ctrl+b p           - Previous window
Ctrl+b [number]    - Jump to window
Ctrl+b &           - Kill window
```

---

## Git

### Initialize Repository
```bash
git init                           # Initialize new repo
git init <directory>               # Create in specific directory
git clone <url>                    # Clone repository
git clone --branch <name> <url>    # Clone specific branch
```

### Staging & Committing
```bash
git add <file>              # Add specific file
git add .                   # Add all changes
git status                  # Show repo status
git diff                    # Changes not staged
git diff --staged           # Changes staged for commit
git diff HEAD               # Difference from last commit
git diff <commit1> <commit2> # Difference between commits

git commit -m "message"     # Commit with message
git commit -a               # Commit all tracked changes
git notes add               # Add notes to commit
```

### Undoing Changes
```bash
git restore <file>          # Discard working changes
git reset <commit>          # Soft reset (keeps changes)
git reset --soft <commit>   # Keep changes in staging
git reset --hard <commit>   # Discard all changes
git revert <commit>         # Create new commit that undoes changes
git revert --no-commit <commit> # Undo without creating commit
```

### File Management
```bash
git rm <file>               # Remove file
git mv <old> <new>          # Move/rename file
```

### Branching & Merging
```bash
git branch                  # List branches
git branch <branch-name>    # Create branch
git branch -d <branch>      # Delete branch
git branch -a               # List all branches (local + remote)
git branch -r               # List remote branches

git checkout <branch>       # Switch to branch
git checkout -b <branch>    # Create and switch to branch
git checkout -- <file>      # Discard changes to file

git merge <branch>          # Merge branch into current
```

### History & Logs
```bash
git log                     # Show commit history
git log <branch>            # History of specific branch
git log --follow <file>     # History including renames
git log --all               # All branches
```

### Stashing
```bash
git stash                   # Stash current changes
git stash list              # Show all stashes
git stash pop               # Apply and remove latest stash
git stash drop              # Remove latest stash
```

### Tags
```bash
git tag                     # List all tags
git tag <tag-name>          # Create lightweight tag
git tag <tag-name> <commit> # Tag specific commit
git tag -a <tag> -m "msg"   # Create annotated tag
```

### Remote Repositories
```bash
git fetch                   # Fetch all changes
git fetch <remote>          # Fetch from specific remote
git fetch --prune           # Remove deleted branches
git pull                    # Fetch and merge
git pull <remote>           # From specific remote
git pull --rebase           # Fetch and rebase

git push                    # Push to remote
git push <remote>           # To specific remote
git push <remote> <branch>  # Specific branch
git push --all              # All branches

git remote                  # List remotes
git remote add <name> <url> # Add new remote
```

### Show Details
```bash
git show                    # Show latest commit details
git show <commit>           # Show specific commit
```

### Commit Message Conventions
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
git commit -m "revert: undo commit"         # Revert
```

---

## AWS Shell Scripting Project

```bash
# List all EC2 instance IDs
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'
```

---

## AWS Services

| Service | Purpose |
|---------|---------|
| **EC2** | Virtual machines (compute) |
| **VPC** | Private, secure network (private subnets, security groups) |
| **EBS** | Block storage for EC2 instances |
| **S3** | Object storage (files, data) - encrypted by default |
| **IAM** | Identity and Access Management (security/permissions) |
| **CloudWatch** | Monitoring, logging, alerts |
| **Lambda** | Serverless compute (short, event-triggered tasks) |
| **CodeBuild** | Build service for CI/CD |
| **CodePipeline** | Orchestrate CI/CD workflows |
| **CodeDeploy** | Automated deployment service |
| **Config** | Configuration management |
| **KMS** | Key Management Service (encryption) |
| **CloudTrail** | API audit logging |
| **ECS** | Container orchestration (AWS proprietary) |
| **EKS** | Managed Kubernetes service |
| **Fargate** | Serverless container compute |
| **ElasticSearch** | Search and analytics |

---

## Configuration Management (Ansible)

### Why Ansible?
- **Push mechanism** (vs Puppet's pull)
- **Agentless** - No agent needed on nodes
- **YAML** - Easy to read language
- **Better Windows support** - Industry standard

### Comparison
| Tool | Mechanism | Language |
|------|-----------|----------|
| Puppet | Pull | Ruby |
| Chef | Pull | Ruby |
| Ansible | Push | YAML |
| Salt | Push | Python |

### Basic Ansible Commands
```bash
# Test connectivity
ansible localhost -m ping

# Using inventory file
ansible -i inventory.ini -m ping all
ansible -i /etc/ansible/hosts.yaml -m ping all
```

### SSH Setup for Ansible
```bash
# Copy SSH key to remote hosts
ssh-copy-id -f "-o IdentityFile <PATH_TO_PEM>" ubuntu@<IP>

# Verify connection
ansible -i inventory.ini -m ping all
```

### Ansible Galaxy & Roles
```bash
# Initialize new role
ansible-galaxy role init test
```

### Ansible Vault (Secrets Management)
```bash
# Create password file
openssl rand -base64 2048 > vault.pass

# Create encrypted secrets
ansible-vault create group_vars/all/pass.yml --vault-password-file vault.pass

# Run playbook with vault
ansible-playbook -i inventory.ini playbook.yml --vault-password-file vault.pass
```

### Ansible Playbooks
```bash
# Syntax check
ansible-playbook --syntax-check playbook.yml

# Run playbook
ansible-playbook -i inventory.ini playbook.yml

# With extra variables (highest precedence)
ansible-playbook -i inventory.ini playbook.yml -e type=t2.large
```

---

## Databases

### MySQL

**Database Operations**
```sql
SHOW DATABASES;
USE test_db;
SELECT DATABASE();
DROP DATABASE test_db;
DESC customers;
```

**Table Operations**
```sql
CREATE TABLE student(id INT, name VARCHAR(100));

INSERT INTO students VALUES (102, "Kishor", "Rajshahi");

SELECT * FROM students WHERE id=101;

UPDATE students SET id = 103 WHERE name="kkp";

DELETE FROM students WHERE id = 104;

DROP TABLE students;
```

**Constraints**
```sql
CREATE TABLE customers3 (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  acc_type VARCHAR(50) NOT NULL DEFAULT "Savings"
);

CREATE TABLE customers4 (
  acc_no INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  acc_type VARCHAR(50) NOT NULL DEFAULT 'savings'
);
```

**String Functions**
```sql
SELECT CONCAT('hey', ' ', 'Kishor');
SELECT CONCAT_WS('-', 'hey', ' ', 'Kishor');
SELECT SUBSTRING('Kishor Kumar Paroi', 1, 6);
SELECT REPLACE(acc_no, 10, 10000) AS new_acc_no FROM customers4;
SELECT REVERSE('hello');
SELECT CHAR_LENGTH('kishor');
SELECT LCASE(type), UPPER(name) FROM customers4;
SELECT INSERT('Hey Wassup', 5, 0, 'Kishor');
SELECT LEFT('hello', 2), RIGHT('hello', 2);
SELECT TRIM('  hello  ');
SELECT REPEAT('ha', 3);
```

**Data Retrieval**
```sql
SELECT DISTINCT acc_type FROM customers4;
SELECT * FROM customers4 ORDER BY name;
SELECT * FROM customers4 ORDER BY name DESC;
SELECT * FROM customers4 WHERE name LIKE "%s___%";
```

**Alterations**
```sql
ALTER TABLE customers4 ADD COLUMN total_cost INT NOT NULL DEFAULT 2000;
UPDATE customers4 SET total_cost=3500 WHERE name LIKE "P%";
```

**Pagination**
```sql
SELECT * FROM customers4 LIMIT 2,4;  # Offset 2, limit 4
SELECT * FROM customers4 ORDER BY total_cost DESC LIMIT 1;
```

**Aggregation**
```sql
SELECT COUNT(*) FROM customers4;
SELECT COUNT(DISTINCT total_cost) FROM customers4;
SELECT COUNT(DISTINCT acc_type) FROM customers4 WHERE total_cost = 3500;
SELECT TOTAL_COST FROM customers4 GROUP BY total_cost;
SELECT total_cost, COUNT(DISTINCT acc_type) FROM customers4 GROUP BY total_cost;
SELECT acc_type, SUM(total_cost) FROM customers4 GROUP BY acc_type;
```

**Date & Time**
```sql
CREATE TABLE person(date DATE, time TIME, datetime DATETIME);
INSERT INTO person VALUES(CURDATE(), CURTIME(), NOW());

SELECT MONTHNAME(NOW());
SELECT DATE_FORMAT(NOW(), '%d/%m/%y');
SELECT DATEDIFF('2024-05-12', '2024-01-11');
SELECT DATE_ADD(NOW(), INTERVAL 30 DAY);
SELECT DATE_SUB(NOW(), INTERVAL 30 DAY);
SELECT TIMEDIFF('23:23:23', '11:11:11');
```

**Auto Timestamp**
```sql
CREATE TABLE blogs(
  blog VARCHAR(200),
  ct DATETIME DEFAULT CURRENT_TIMESTAMP,
  ut DATETIME ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO blogs(blog) VALUES('this is my first blog');
UPDATE blogs SET blog='this is second blog';  # ut updates automatically
```

**Relationships & Joins**
```sql
-- Create tables with foreign key
CREATE TABLE customers (
  cust_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(200)
);

CREATE TABLE orders (
  ord_id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE,
  amount DECIMAL(10,2),
  cust_id INT,
  FOREIGN KEY (cust_id) REFERENCES customers(cust_id) ON DELETE CASCADE
);

-- Check constraints
SELECT constraint_name, column_name, referenced_table_name
FROM information_schema.key_column_usage
WHERE table_name='orders';

-- Insert data
INSERT INTO orders(date, amount, cust_id) VALUES (CURDATE(), 504.88, 30);

-- Join tables
SELECT * FROM customers
INNER JOIN orders ON orders.cust_id=customers.cust_id;
```

**Complex Queries**
```sql
-- Multi-table join
SELECT student_name, course_name
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON courses.id=student_course.course_id;

-- Count enrollments
SELECT course_name, COUNT(student_id) AS enrolled_count
FROM courses
JOIN student_course ON student_course.course_id=courses.id
JOIN students ON student_course.student_id=students.id
GROUP BY course_name;

-- Course count and fees
SELECT student_name, COUNT(course_id) AS takenCourseCount, SUM(fees) AS totalFee
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON courses.id=student_course.course_id
GROUP BY student_name;
```

**Views & CASE Statements**
```sql
-- Create view
CREATE VIEW inst_info AS
SELECT student_name, course_name, fees
FROM students
JOIN student_course ON student_course.student_id=students.id
JOIN courses ON student_course.course_id=courses.id;

-- CASE with conditions
SELECT
  student_name,
  SUM(fees) AS totalFee,
  CASE
    WHEN SUM(fees) BETWEEN 3000 AND 4999 THEN 'Borolok'
    WHEN SUM(fees) < 3000 THEN 'Gorib'
    WHEN SUM(fees) >= 5000 THEN 'Ultra borolok'
  END AS status
FROM inst_info
GROUP BY student_name;

-- WITH ROLLUP for totals
SELECT
  IFNULL(student_name, "Total") AS Name,
  SUM(fees) AS totalFee,
  CASE
    WHEN SUM(fees) BETWEEN 3000 AND 4999 THEN 'Borolok'
    WHEN SUM(fees) < 3000 THEN 'Gorib'
    ELSE 'Ultra borolok'
  END AS status
FROM inst_info
GROUP BY student_name WITH ROLLUP;
```

---

### PostgreSQL

```bash
\l              # List databases
\c test         # Connect to test database
\!cls           # Clear screen
```

---

## Docker

### Container Basics
```bash
docker run busybox echo hi kkp        # Run command in container
docker ps                             # List running containers
docker ps -a                          # List all containers
docker system prune                   # Remove unused resources
```

### Create vs Run
```bash
docker create busybox echo hi         # Create container (not started)
docker start <container_id>           # Start container

# Run = create + start
docker run busybox echo hi
```

### Container Logs & Interaction
```bash
docker logs <container_id>            # View container output
docker logs -f <container_id>         # Follow logs

# Interactive shell
docker exec -it <container_id> sh     # -i stdin, -t beautify
docker run -it busybox sh             # Create new container with shell
```

### Container Lifecycle
```bash
docker stop <container_id>            # Graceful stop (10s timeout)
docker kill <container_id>            # Force kill immediately
```

### Image Management
```bash
docker build .                        # Build image from Dockerfile
docker build -t mywebapp:02 .         # Build with tag

docker image ls                       # List images
docker rmi <image_id>                 # Remove image
docker rmi -f <image_id>              # Force remove
```

### Container Ports & Persistence
```bash
# Port mapping
docker run -d --rm --name myapp -p 5174:3000 <image_id>
# -d: detach (background)
# --rm: auto-remove on stop
# -p: port mapping (host:container)

# Volume (persistent storage)
docker run -t --rm -v myvolume:/myapp/ <image_id>

# Bind mount (local directory)
docker run -v /local/path:/container/path --rm <image_id>
```

### Cleanup
```bash
docker container prune                # Remove stopped containers
docker system prune -af               # Remove all unused resources
```

---

## Kubernetes

### Minikube Setup
```bash
minikube start                        # Start minikube cluster
minikube status                       # Check status
minikube dashboard                    # Open web dashboard
```

### Deployments
```bash
# Create deployment
kubectl create deployment my-nginx --image=nginx:latest

# View deployments and pods
kubectl get deployments
kubectl get pods

# Describe pod
kubectl describe pod <pod_name>
```

### Scaling
```bash
kubectl scale deployment my-nginx --replicas=3    # Scale up
kubectl scale deployment my-nginx --replicas=2    # Scale down
```

### Services (Expose)
```bash
# Expose deployment
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer
kubectl expose deployment my-webapp --type=LoadBalancer --port=3002

# Access service
minikube service my-nginx

# Port forward to pod
kubectl port-forward pod/<pod_name> 3000:3000
```

### Deployment Management
```bash
# Delete deployment
kubectl delete deployment my-web-app

# Delete pod (replacement starts automatically)
kubectl delete pod <pod_name>
```

### Updates & Rollouts
```bash
# Update image
kubectl set image deployment my-webapp web-app=<new-image>:04

# Check rollout status
kubectl rollout status deployment my-webapp

# Undo to previous version
kubectl rollout undo deployment my-webapp
```

### Configuration Files
```bash
# Apply configuration
kubectl apply -f deploy.yml

# Delete from configuration
kubectl delete -f deploy.yml
```

### Docker Networks with Kubernetes
```bash
# Create network
docker network create my-net

# Run MongoDB
docker run -d -p 27017:27017 --network my-net --name mongo mongo

# Run app
docker run --network my-net -p 3000:3000 --name myapp <image>
```

---

## Terraform

### AWS Credentials Setup

⚠️ **NEVER commit credentials to version control!**

Use one of these secure methods:

#### Method 1: AWS CLI Configuration (Recommended)
```bash
aws configure
# Interactive prompts:
AWS Access Key ID: [enter your key]
AWS Secret Access Key: [enter your secret]
Default region: us-east-1
Default output format: json

# Credentials stored securely in ~/.aws/credentials
```

#### Method 2: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Or add to ~/.bashrc for persistence
```

#### Method 3: IAM Roles (Best for EC2)
```bash
# Attach IAM role to EC2 instance
# No credentials needed - automatically assumed!
```

#### Method 4: AWS SSO
```bash
aws sso login --profile your-profile
# Opens browser for login
```

### Terraform Workflow
```bash
terraform init              # Initialize Terraform
terraform plan              # Show what will change
terraform apply             # Apply changes
terraform destroy           # Destroy infrastructure
terraform validate          # Check syntax
terraform fmt               # Format files
```

### Common Terraform Commands
```bash
# Variables
terraform var AWS_REGION=us-east-1
terraform var-file="vars.tfvars"

# State management
terraform state list        # List all resources
terraform state show        # Show specific resource
terraform state rm          # Remove from state

# Debugging
terraform console           # Interactive console
terraform graph             # Show resource graph
terraform output            # Show output values
```

---

## Ultimate DevOps Project

### System Cleanup
```bash
# Clear RAM
sudo sync && sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches' && echo "RAM cleared!"
free -h

# Clean Docker
docker system prune -af

# Restart services
sudo systemctl restart docker
```

### Install Dependencies
```bash
# Go
sudo apt-get install golang-go

# Java JRE
sudo apt install openjdk-21-jre-headless
```

### Copy Files to EC2
```bash
# Upload PEM key
sudo scp -i ./bastion.pem ./devOps-demo.pem ubuntu@54.196.55.201:/home/ubuntu
```

### Keep Process Running with PM2
```bash
# Install Node.js & PM2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

# Enable startup
pm2 startup
# Copy and run the output command

# Start application
pm2 start "python3 -m http.server 3001" --name "website"

# Make persistent
pm2 save
pm2 startup
pm2 save

# Verify
pm2 list

# Server runs even after logout!
pm2 list              # Check running processes
pm2 stop website      # Stop app
pm2 restart website   # Restart app
pm2 delete website    # Remove from PM2
pm2 logs website      # View logs
```

---

## Key Learnings

✅ **DevOps Tools Stack:**
- Infrastructure: AWS EC2, VPC, EBS, S3
- Containerization: Docker, Kubernetes
- IaC: Terraform
- Configuration: Ansible
- CI/CD: GitHub Actions, Jenkins, AWS CodePipeline
- Monitoring: CloudWatch, Prometheus, ELK

✅ **Linux Mastery:**
- Command line proficiency
- Shell scripting
- System administration
- User/permission management

✅ **Cloud Architecture:**
- Network design
- Security groups
- Auto-scaling
- Load balancing

✅ **Best Practices:**
- Always use configuration management
- Automate everything
- Monitor everything
- Keep systems updated with security patches

---

**Last Updated:** December 21, 2025
**Status:** 🔄 In Progress
**Difficulty:** Intermediate → Advanced