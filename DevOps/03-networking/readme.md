# Networking & Network Diagnostics 🌐

Network commands, packet capture, and volume management.

---

## TCP Packet Capture with tcpdump

Monitor network traffic and analyze packets.

### Capture Packets from/to Specific IP
```bash
# Capture packets from/to specific IP
sudo tcpdump -vni en0 src 216.58.200.174 or dst 216.58.200.174
```

### Capture ICMP Packets
```bash
# Ping/ICMP traffic
sudo tcpdump -vni icmp
```

### Capture All Traffic on Interface
```bash
# Monitor all traffic on interface
sudo tcpdump -vni en0
```

---

## External Volume Management

Attach, mount, and manage external volumes on EC2.

### Step 1: Format the Volume
```bash
# Create XFS file system
sudo mkfs -t xfs /dev/xvdf
```

### Step 2: Check File System
```bash
sudo file -s /dev/xvdf
```

### Step 3: Mount Volume
```bash
sudo mount /dev/xvdf mountFolder/
```

### Step 4: Check Mounted Volumes
```bash
df -k
```

### Step 5: Resize Volume

#### For ext4:
```bash
resize2fs /dev/xvdf
```

#### For XFS:
```bash
sudo xfs_growfs /home/ubuntu/mountFolder
```

---

## Common Networking Tools

| Tool | Purpose |
|------|---------|
| `tcpdump` | Capture and analyze packets |
| `netstat` | Show network connections |
| `ping` | Test connectivity (ICMP) |
| `traceroute` | Trace network path to host |
| `dig` | DNS lookup tool |
| `nslookup` | Query DNS servers |
| `curl` | Test HTTP connectivity |
| `wget` | Download files |
| `ssh` | Secure shell connection |
| `scp` | Secure copy between hosts |

---

**Last Updated:** December 22, 2025
