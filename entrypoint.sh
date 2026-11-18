#!/bin/bash

# Ensure bash history links to /dev/null per DockerLabs guidelines
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/mario/.bash_history

# Remove default Ubuntu index.html to guarantee index.php is loaded
rm -f /var/www/html/index.html

# Fix web permissions (directories 755, files 644)
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} +
find /var/www/html -type f -exec chmod 644 {} +

# Setup user and backup permissions
chown -R mario:mario /home/mario
chmod 600 /home/mario/user.txt 2>/dev/null
chmod 600 /root/root.txt 2>/dev/null

# Intermediate flag restricted to mario only
chown -R mario:mario /opt/backup
chmod 600 /opt/backup/notes.txt 2>/dev/null
chmod 755 /opt/backup/rotate.sh 2>/dev/null

# Ensure runtime directories exist for Apache
mkdir -p /var/run/apache2 /var/lock/apache2 /var/log/apache2
chown -R www-data:www-data /var/run/apache2 /var/lock/apache2 /var/log/apache2

# Start background cron service for scheduled tasks
echo "[+] Starting cron service..."
service cron start

# Generate stable instance token for the debug bridge
DEBUG_TOKEN=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')
echo "$DEBUG_TOKEN" > /run/debug_token
chmod 644 /run/debug_token

echo "[+] Starting Apache2 Web Server on php2shell.dl..."
source /etc/apache2/envvars 2>/dev/null
exec /usr/sbin/apache2ctl -D FOREGROUND
