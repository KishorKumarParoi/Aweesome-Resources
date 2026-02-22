# Tomcat Server Setup for Ubuntu

## Overview
Apache Tomcat is an open-source Java application server that runs Java servlets and JSP web applications. This guide covers installation and configuration on Ubuntu with a custom port setup.

---

## Quick Setup Script

Here's a complete list of commands to set up Tomcat from scratch:

```bash
# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Java 11 JDK
sudo apt install openjdk-11-jdk -y
java -version

# Create tomcat user
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download and extract Tomcat 10.1.5
cd /opt
sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.5/bin/apache-tomcat-10.1.5.tar.gz
sudo tar -xf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components=1

# Set permissions
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

# Configure systemd service
sudo vi /etc/systemd/system/tomcat.service

# Enable and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status tomcat

# Configure Tomcat users
sudo vi /opt/tomcat/conf/tomcat-users.xml

# Verify Tomcat is running
curl localhost:8080

# Configure firewall rules
sudo ufw allow 8080/tcp
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status

# Check Tomcat again
curl localhost:8080
```

---

## Prerequisites

- Ubuntu 18.04 or later
- Java Development Kit (JDK) installed
- Sudo access
- Terminal/SSH access

---

## Step 1: Install Java (JDK)

Tomcat requires Java to run. Install OpenJDK:

```bash
sudo apt-get update
sudo apt-get install -y default-jdk
```

Verify Java installation:

```bash
java -version
javac -version
```

---

## Step 2: Create a Dedicated User for Tomcat

It's recommended to run Tomcat as a non-root user for security:

```bash
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
```

---

## Step 3: Download and Install Tomcat

Navigate to `/opt` directory and download Tomcat:

```bash
cd /opt
sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.13/bin/apache-tomcat-10.1.13.tar.gz
```

> **Note:** Replace the version number with the latest stable version if needed. Check [Apache Tomcat Downloads](https://tomcat.apache.org/)

Extract the archive:

```bash
sudo tar -xzf apache-tomcat-10.1.13.tar.gz
sudo mv apache-tomcat-10.1.13 tomcat
```

Set proper permissions:

```bash
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R u+x /opt/tomcat/bin
```

---

## Step 4: Configure Environment Variables

Create a systemd service file for Tomcat:

```bash
sudo vi /etc/systemd/system/tomcat.service
```

Add the following content:

```ini
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xmx512M -Xms512M"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

Save and exit (Ctrl+X, then Y, then Enter).

---

## Step 5: Change Default Port from 8080 to 5000

Edit the Tomcat configuration file:

```bash
sudo vi /opt/tomcat/conf/server.xml
```

Find the line with port 8080 (usually around line 69):

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

Replace `8080` with `5000`:

```xml
<Connector port="5000" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

Save and exit (Ctrl+X, then Y, then Enter).

---

## Step 6: Update Firewall Rules

Allow traffic on port 5000:

```bash
sudo ufw allow 5000/tcp
```

For UFW (if not already enabled):

```bash
sudo ufw enable
sudo ufw status
```

---

## Step 7: Start Tomcat Service

Reload systemd and start Tomcat:

```bash
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat   # Enable auto-start on reboot
```

Check the status:

```bash
sudo systemctl status tomcat
```

---

## Step 8: Verify Tomcat Installation

Check if Tomcat is running on port 5000:

```bash
curl http://localhost:5000
```

Or access via browser: `http://your_server_ip:5000`

---

## Useful Tomcat Commands

### Start Tomcat
```bash
sudo systemctl start tomcat
```

### Stop Tomcat
```bash
sudo systemctl stop tomcat
```

### Restart Tomcat
```bash
sudo systemctl restart tomcat
```

### View Tomcat Logs
```bash
tail -f /opt/tomcat/logs/catalina.out
```

### View all logs
```bash
ls -la /opt/tomcat/logs/
```

---

## Tomcat Manager Web Application

### Enable Tomcat Manager

Edit the users configuration file:

```bash
sudo vi /opt/tomcat/conf/tomcat-users.xml
```

Add the following lines before `</tomcat-users>`:

```xml
<role rolename="manager-gui"/>
<user username="admin" password="your_secure_password" roles="manager-gui"/>
<role rolename="admin-gui"/>
<user username="tomcat_admin" password="your_secure_password" roles="admin-gui"/>
```

Save the file and restart Tomcat:

```bash
sudo systemctl restart tomcat
```

Access the manager at: `http://your_server_ip:5000/manager/html`

---

## Troubleshooting

### Port Already in Use
If port 5000 is already in use:

```bash
sudo lsof -i :5000
# Kill the process using that port
sudo kill -9 <PID>
```

### Permission Denied Error
Ensure proper permissions:

```bash
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R u+x /opt/tomcat/bin
```

### Tomcat Won't Start
Check the logs:

```bash
sudo tail -f /opt/tomcat/logs/catalina.out
```

### Firewall Blocking

Ensure port 5000 is open:

```bash
sudo ufw allow 5000/tcp
sudo ufw reload
```

---

## Performance Tuning

Edit `/etc/systemd/system/tomcat.service` to adjust JVM memory:

```ini
Environment="CATALINA_OPTS=-Xmx1024M -Xms512M"
```

- `-Xmx1024M`: Maximum heap size (1GB)
- `-Xms512M`: Initial heap size (512MB)

After changes, restart the service:

```bash
sudo systemctl daemon-reload
sudo systemctl restart tomcat
```

---

## Security Best Practices

1. **Disable Unnecessary Services:**
   ```bash
   sudo rm -rf /opt/tomcat/webapps/examples
   sudo rm -rf /opt/tomcat/webapps/docs
   ```

2. **Change Default Credentials:** Always change default usernames and passwords in `tomcat-users.xml`

3. **Run as Non-Root User:** (Already configured in this guide)

4. **Keep Tomcat Updated:** Regularly check for security patches

5. **Use HTTPS:** Configure SSL/TLS for production environments

---

## References

- [Apache Tomcat Official Documentation](https://tomcat.apache.org/)
- [Java Installation on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu)
- [Systemd Service Management](https://www.freedesktop.org/software/systemd/man/systemctl.html)

