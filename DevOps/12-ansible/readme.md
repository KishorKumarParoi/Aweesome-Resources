# Ansible Configuration Management 🔧

Infrastructure automation with Ansible for agentless configuration management.

---

## Why Ansible?

Advantages over other configuration management tools:

| Feature | Ansible | Puppet | Chef |
|---------|---------|--------|------|
| **Mechanism** | Push | Pull | Pull |
| **Agents** | Agentless | Agent-based | Agent-based |
| **Language** | YAML | Ruby | Ruby |
| **Complexity** | Simple | Complex | Complex |
| **Windows Support** | Excellent | Good | Good |
| **Learning Curve** | Easy | Medium | Hard |

### Key Benefits
- ✅ Simple YAML syntax
- ✅ No agents to install on nodes
- ✅ Push-based (you control when changes happen)
- ✅ Great for ad-hoc commands
- ✅ Excellent documentation

---

## Basic Ansible Commands

### Test Connectivity

```bash
# Test connection to localhost
ansible localhost -m ping

# Using inventory file
ansible -i inventory.ini -m ping all
ansible -i /etc/ansible/hosts.yaml -m ping all

# Test with verbosity
ansible -i inventory.ini -m ping all -vvv
```

---

## SSH Setup for Ansible

### Copy SSH Key to Remote Hosts

```bash
# Copy SSH key to remote server
ssh-copy-id -f "-o IdentityFile <PATH_TO_PEM>" ubuntu@<IP>

# Example:
ssh-copy-id -f "-o IdentityFile ~/.ssh/id_rsa" ubuntu@192.168.1.100

# Verify connection
ansible -i inventory.ini -m ping all
```

---

## Ansible Inventory

### Create Inventory File

```ini
# inventory.ini
[webservers]
web1.example.com
web2.example.com

[databases]
db1.example.com

[all:vars]
ansible_user=ubuntu
ansible_private_key_file=~/.ssh/id_rsa
```

### YAML Format

```yaml
# hosts.yaml
webservers:
  hosts:
    web1.example.com:
    web2.example.com:
databases:
  hosts:
    db1.example.com:
all:
  vars:
    ansible_user: ubuntu
    ansible_private_key_file: ~/.ssh/id_rsa
```

---

## Ansible Playbooks

### Basic Playbook Structure

```yaml
---
- name: Install and start Nginx
  hosts: webservers
  become: yes
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    
    - name: Start Nginx service
      systemd:
        name: nginx
        state: started
        enabled: yes
```

### Run Playbook

```bash
# Syntax check
ansible-playbook --syntax-check playbook.yml

# Run playbook
ansible-playbook -i inventory.ini playbook.yml

# With extra variables (highest precedence)
ansible-playbook -i inventory.ini playbook.yml -e type=t2.large

# Dry run (check mode)
ansible-playbook -i inventory.ini playbook.yml --check

# Verbose output
ansible-playbook -i inventory.ini playbook.yml -v
ansible-playbook -i inventory.ini playbook.yml -vvv
```

---

## Ansible Galaxy & Roles

### Initialize New Role

```bash
# Create role structure
ansible-galaxy role init my_role

# Role directory structure
my_role/
├── defaults/        # Default variables
├── files/          # Files to copy
├── handlers/       # Event handlers
├── meta/           # Role metadata
├── tasks/          # Main tasks
├── templates/      # Jinja2 templates
└── vars/           # Role variables
```

### Use Roles in Playbook

```yaml
---
- name: Deploy web server
  hosts: webservers
  roles:
    - common
    - nginx
    - my_role
```

---

## Ansible Vault (Secrets Management)

### Create Secure Password File

```bash
# Generate strong random password
openssl rand -base64 2048 > vault.pass

# Protect the file
chmod 600 vault.pass
```

### Create Encrypted Secrets

```bash
# Create encrypted variables file
ansible-vault create group_vars/all/pass.yml --vault-password-file vault.pass

# Example secrets file
db_password: "super_secret_password"
api_key: "your_api_key"
```

### Run Playbook with Vault

```bash
# Supply vault password file
ansible-playbook -i inventory.ini playbook.yml --vault-password-file vault.pass

# Prompt for password
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass

# Edit encrypted file
ansible-vault edit group_vars/all/pass.yml --vault-password-file vault.pass
```

---

## Common Ansible Modules

### Package Management

```yaml
- name: Install package
  apt:
    name: git
    state: present

- name: Update all packages
  apt:
    upgrade: dist
```

### File Operations

```yaml
- name: Copy file
  copy:
    src: local/file
    dest: /remote/file
    owner: user
    group: group
    mode: '0644'

- name: Create directory
  file:
    path: /opt/myapp
    state: directory
    mode: '0755'
```

### Service Management

```yaml
- name: Start service
  systemd:
    name: nginx
    state: started
    enabled: yes

- name: Restart service
  systemd:
    name: nginx
    state: restarted
```

### Templates

```yaml
- name: Deploy config from template
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx
```

---

## Handlers & Notifications

Handlers run only when notified (like event listeners).

```yaml
---
- name: Configure Nginx
  hosts: webservers
  become: yes
  
  tasks:
    - name: Deploy Nginx config
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: restart nginx
  
  handlers:
    - name: restart nginx
      systemd:
        name: nginx
        state: restarted
```

---

## Variables & Facts

### Use Variables

```yaml
- name: Deploy application
  hosts: webservers
  vars:
    app_port: 8080
    app_user: appuser
  
  tasks:
    - name: Start application
      command: /opt/app/start.sh --port {{ app_port }} --user {{ app_user }}
```

### Gather Facts

```bash
# Get system information
ansible -i inventory.ini all -m setup | less

# Filter specific facts
ansible -i inventory.ini all -m setup -a "filter=ansible_os_family"
```

---

## Quick Reference

| Task | Command |
|------|---------|
| **Test connectivity** | `ansible -i inventory.ini -m ping all` |
| **Run ad-hoc command** | `ansible -i inventory.ini all -m command -a "ls -la"` |
| **Syntax check** | `ansible-playbook --syntax-check playbook.yml` |
| **Dry run** | `ansible-playbook playbook.yml --check` |
| **With variables** | `ansible-playbook playbook.yml -e key=value` |
| **With vault** | `ansible-playbook playbook.yml --vault-password-file vault.pass` |
| **List roles** | `ansible-galaxy role list` |
| **Create role** | `ansible-galaxy role init my_role` |

---

**Last Updated:** December 22, 2025
