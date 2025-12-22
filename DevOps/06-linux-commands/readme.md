# Linux Commands Mastery 💻

Essential Linux commands for file operations, networking, compression, and text processing.

---

## File Operations

### Listing & Navigation
```bash
# List with human-readable sizes
ls -lh

# More vs Less
more file.txt    # Print to terminal
less file.txt    # Open in pager editor
```

### Sorting & Filtering
```bash
# Sort lines
sort data.txt | uniq

# Split files into chunks
split -l 3 data.txt

# Search patterns (extended regex)
egrep "dolor|Dolan" test.json

# Wildcard patterns
ls *.sh          # All shell files
ls x*            # Files starting with x
touch file{1..10} # Create 10 files
```

### File Analysis
```bash
# Shuffle content randomly
shuf test.json

# Count lines, words, bytes
wc -l test.json

# Compare files
cmp test.json Linux_Command.pdf
diff -u file1 file2

# Find files by name
find ./folder/ -name test.json
find . -name xaa
find ./Projects/ -name test.json

# macOS find in spotlight
mdfind "kind:pdf AND Linux"

# Linux locate (fast search, needs updatedb)
locate test.json
updatedb  # Update locate database
```

---

## Compression & Archives

### Gzip
```bash
# Compress (keep original)
gzip -k test.json

# Decompress
gzip -d test.json.gz
```

### Tar (Archive + Compress)
```bash
# Create compressed archive
tar -czf compress_folder.tar.gz folder/

# Extract archive
tar -xzf compress_folder.tar.gz
```

### Zip
```bash
# Create zip archive
zip files.zip file1 file2

# Extract zip
unzip files.zip

# List zip contents
unzip -l files.zip
```

---

## Network & Download

### HTTP Requests
```bash
# Make HTTP request
curl http://numberapi.com/random
```

### Download Files
```bash
# Linux wget
wget -o kkp.txt url_link

# macOS alternative (curl)
curl url -o output.txt
```

---

## Package Management

### RedHat/CentOS
```bash
# Install package
sudo yum install nginx

# List installed packages matching pattern
rpm -qa | grep sql
```

### macOS (Homebrew)
```bash
# List installed packages
brew list | grep nginx
```

### Debian/Ubuntu
```bash
# List installed packages
dnf list installed
```

---

## Text Processing

### AWK (Powerful field/record processing)
```bash
# Print specific column
awk -F, '{print $2}' test.csv

# Print last column
awk -F, '{print $NF}' test.csv

# Combine multiple columns
awk -F, '{print $NF$2$3}' test.csv
```

### CUT (Extract columns)
```bash
# Extract characters 3-10
cut -c3-10 test.csv
```

### SED (Stream editor)
```bash
# Print specific line
sed -n '5p' test.csv

# Replace globally
sed -n 's/gmail/kkpmail/g' test.csv
```

### TR (Translate/delete characters)
```bash
# Delete specific characters
tr -d '10' < test.csv

# Convert to lowercase
tr [:upper:] [:lower:] < test.csv
```

---

## File Size & Viewing

### Truncate File
```bash
# Limit file to 50MB
truncate -s 50M file.txt
```

### Fold Characters
```bash
# Fold into single characters
cat test.csv | fold -w1
```

---

## File Transfer

### Secure Copy
```bash
# Copy file to remote server
scp file user@hostname:/tmp/
```

---

## Permissions & Ownership

### Change Owner/Group
```bash
# Change owner
chown kkp file.txt

# Change group
chgrp kkp file.txt
```

---

## Process Management

### Find Process
```bash
# Find process by name
pgrep chron

# Show detailed process info
ps aux

# Monitor processes interactively
top
htop
```

---

## Utilities

### Calculator
```bash
bc
```

### Calendar
```bash
cal
cal 100
```

### Session Recording
```bash
# Record terminal session
script
# (press Ctrl+D to stop)
```

### Aliases
```bash
# Create alias
alias l="ls -ltr"
```

---

## Environment Variables

### View & Source
```bash
# View environment variables
printenv | grep TESTVAR

# Source bashrc for persistent changes
source ~/.bashrc
```

---

**Last Updated:** December 22, 2025
