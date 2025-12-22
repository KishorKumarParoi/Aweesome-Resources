# Linux Fundamentals & OS Architecture 🐧

Understanding Linux, operating systems, and kernel architecture.

---

## Linux Advantages

Why choose Linux for DevOps?

| Feature | Benefit |
|---------|---------|
| **Free** | No licensing costs |
| **Fast** | Lightweight and efficient |
| **Open Source** | Community-driven development |
| **Secure** | Robust security features |
| **Portable** | Runs on any hardware |
| **Stable** | Excellent uptime |

---

## Operating System Architecture

### OS Layer Stack

```
┌─────────────────────────────────────┐
│     Applications/User Programs      │
│  (Web servers, databases, shells)   │
├─────────────────────────────────────┤
│        System Libraries & APIs      │
│  (libc, standard library functions) │
├─────────────────────────────────────┤
│     Shell & Utilities Programs      │
│  (bash, grep, ls, awk, sed, etc)    │
├─────────────────────────────────────┤
│   ⭐ KERNEL (Heart of Operating OS)│
│  (Memory, Process, File, Device)    │
├─────────────────────────────────────┤
│    Hardware Layer (CPU, Memory,     │
│    Disk, Network, Peripherals)      │
└─────────────────────────────────────┘
```

---

## Kernel Responsibilities

The **kernel** is the core of the OS managing:

### 1. Process Management
- Process creation, scheduling, termination
- Context switching between processes
- Signal handling

### 2. Memory Management
- Virtual memory
- Memory allocation & deallocation
- Paging & swapping

### 3. File System
- File organization
- Directory structure
- Access control & permissions
- Read/write operations

### 4. Device Management
- Device drivers
- Hardware communication
- I/O operations
- Interrupt handling

### 5. Networking
- Network protocols (TCP/IP)
- Socket management
- Data transmission

### 6. Security & Access Control
- User/group management
- Permission checks
- Resource protection

---

## Kernel vs Shell

| Aspect | Kernel | Shell |
|--------|--------|-------|
| **Role** | Core OS, manages resources | User interface to OS |
| **Language** | C (mostly) | Bash, Zsh, Fish, etc. |
| **Access** | Direct hardware access | Communicates via kernel |
| **Stability** | Rarely changes | User-configurable |
| **Example** | Linux, Windows kernel | bash, zsh, PowerShell |

---

## How Programs Run

1. **User** types command in **Shell**
2. **Shell** sends request to **Kernel**
3. **Kernel** allocates resources (memory, CPU)
4. **Program** executes using **System Libraries**
5. **Program** calls **Kernel** for I/O (files, network)
6. **Kernel** returns results to **Program**
7. **Program** output displayed by **Shell**

---

**Last Updated:** December 22, 2025
