FROM ubuntu:22.04

# OCI Annotations
LABEL org.opencontainers.image.title="PHP2Shell" \
      org.opencontainers.image.description="DockerLabs Educational Challenge - Legacy Debug Bridge & Privilege Escalation" \
      org.opencontainers.image.authors="DockerLabs Community" \
      org.opencontainers.image.version="1.1"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Madrid

# Install Apache2, PHP, cron, and basic system utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    php \
    libapache2-mod-php \
    php-cli \
    php-common \
    cron \
    curl \
    iputils-ping \
    net-tools \
    iproute2 \
    procps \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite and headers modules
RUN a2enmod rewrite headers

# Configure VirtualHost
COPY config/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

# Setup local user 'mario' with a secure credential
RUN useradd -m -s /bin/bash mario && \
    echo "mario:mario_chocolate!" | chpasswd

# Setup CTF User Flag
RUN echo "dl{m4r10_l3g4cy_d3bug_pwn3d_4f7e}" > /home/mario/user.txt && \
    chown mario:mario /home/mario/user.txt && \
    chmod 600 /home/mario/user.txt

# Setup CTF Root Flag
RUN echo "dl{r00t_sCH3dul3r_3sc4l4t10n_99c3}" > /root/root.txt && \
    chmod 600 /root/root.txt

# Setup /opt/backup with intermediate flag and scheduled maintenance script
RUN mkdir -p /opt/backup && \
    echo "dl{l3gacy_cr0n_m41nt3n4nc3_fl4g_88a1}" > /opt/backup/notes.txt && \
    echo '#!/bin/bash\n# Scheduled log rotation task\ntar -czf /tmp/backup_logs.tar.gz /var/log/apache2/*.log 2>/dev/null\n' > /opt/backup/rotate.sh && \
    chown -R mario:mario /opt/backup && \
    chmod 644 /opt/backup/notes.txt && \
    chmod 755 /opt/backup/rotate.sh

# Configure cron task running rotate.sh as root every minute
RUN echo "* * * * * root /opt/backup/rotate.sh" > /etc/cron.d/backup_rotate && \
    chmod 0644 /etc/cron.d/backup_rotate

# Deploy Web Application (remove default Ubuntu index.html first)
RUN rm -rf /var/www/html/*
COPY html/ /var/www/html/

# Add database config and developer note in /var/www readable by www-data
RUN echo '<?php\n// Internal database & system management\n$db_host = "127.0.0.1";\n$db_user = "mario";\n$db_pass = "mario_chocolate!";\n$db_name = "corp_cloud";\n?>' > /var/www/config_db.php && \
    echo '[INTERNAL DEVELOPER NOTE]\nRecordatorio: La credencial del usuario local mario coincide con el acceso a la base de datos definido en config_db.php.' > /var/www/dev_notes.txt && \
    chown www-data:www-data /var/www/config_db.php /var/www/dev_notes.txt && \
    chmod 644 /var/www/config_db.php /var/www/dev_notes.txt

# DockerLabs rule: nullify bash histories
RUN ln -sf /dev/null /root/.bash_history && \
    ln -sf /dev/null /home/mario/.bash_history

# Setup entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Healthcheck definition
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/status.php || exit 1

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
