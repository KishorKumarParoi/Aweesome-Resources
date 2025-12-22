# Kode Kloud Learning Resources 🎓

Important system commands and concepts from Kode Kloud courses.

---

## System Commands

Essential commands for understanding OS and system internals.

### Architecture & Kernel
```bash
# Show kernel release version
uname -r

# Display kernel messages
dmesg

# List PCI devices (hardware)
lspci

# Monitor device events in real-time
udevadm monitor
```

### Memory & Hardware
```bash
# Display memory information
lsmem

# List hardware information
lshw
```

### Useful Aliases
```bash
# Shortcut for kubectl
k
```

---

## 12 Factor App

Principles for building scalable, maintainable applications:

1. **Codebase** - Single codebase tracked in version control
2. **Dependencies** - Explicitly declare and isolate dependencies
3. **Config** - Store configuration in environment variables
4. **Backing Services** - Treat databases/queues as attached resources
5. **Build/Release/Run** - Strictly separate build, release, and run stages
6. **Processes** - Execute app as stateless processes
7. **Port Binding** - Export HTTP via port binding
8. **Concurrency** - Export concurrency via process model
9. **Disposability** - Maximize robustness with fast startup/shutdown
10. **Dev/Prod Parity** - Keep dev, staging, prod as similar as possible
11. **Logs** - Write logs to stdout/stderr
12. **Admin Processes** - Run admin tasks as one-off processes

---

**Last Updated:** December 22, 2025
