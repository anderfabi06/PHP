#!/bin/bash

# Ensure bash history links to /dev/null per DockerLabs guidelines
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/mario/.bash_history

# Fix permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

chown -R mario:mario /home/mario
chmod 600 /home/mario/user.txt 2>/dev/null
chmod 600 /root/root.txt 2>/dev/null

# Ensure runtime directories exist for Apache
mkdir -p /var/run/apache2 /var/lock/apache2 /var/log/apache2
chown -R www-data:www-data /var/run/apache2 /var/lock/apache2 /var/log/apache2

echo "[+] Starting Apache2 Web Server on php2shell.dl..."
source /etc/apache2/envvars 2>/dev/null
exec /usr/sbin/apache2ctl -D FOREGROUND
