#!/bin/bash

# Ensure bash history links to /dev/null per DockerLabs guidelines
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/mario/.bash_history

# Fix permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

chown -R mario:mario /home/mario
chmod 600 /home/mario/user.txt
chmod 600 /root/root.txt

# Start Apache in foreground
echo "[+] Starting Apache2 Web Server on php2shell.dl..."
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
