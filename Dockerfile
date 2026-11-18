FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Madrid

# Install necessary packages: Apache2, PHP, sudo, basic utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    php \
    libapache2-mod-php \
    php-cli \
    php-common \
    sudo \
    curl \
    iputils-ping \
    net-tools \
    iproute2 \
    procps \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite and headers
RUN a2enmod rewrite headers

# Configure VirtualHost
COPY config/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

# Setup local user 'mario' with password 'chocolate' (Top 5000 in rockyou.txt)
RUN useradd -m -s /bin/bash mario && \
    echo "mario:chocolate" | chpasswd

# Setup sudoers privilege escalation vector for mario: GTFOBins /usr/bin/php
RUN echo "mario ALL=(root) NOPASSWD: /usr/bin/php" >> /etc/sudoers.d/mario && \
    chmod 0440 /etc/sudoers.d/mario

# Setup CTF Flags
RUN echo "dl{php2shell_uaf_00m_c0rrupti0n_9a2b}" > /home/mario/user.txt && \
    chown mario:mario /home/mario/user.txt && \
    chmod 600 /home/mario/user.txt

RUN echo "dl{php_c0re_3ng1n3_pwn3d_cve2026_x86}" > /root/root.txt && \
    chmod 600 /root/root.txt

# Deploy Web Application
COPY html/ /var/www/html/

# Add database/backup config file with credentials readable by www-data
RUN echo '<?php\n// Internal database & system management\n$db_host = "127.0.0.1";\n$db_user = "mario";\n$db_pass = "chocolate";\n$db_name = "corp_cloud";\n?>' > /var/www/config_db.php && \
    chown www-data:www-data /var/www/config_db.php && \
    chmod 644 /var/www/config_db.php

# DockerLabs rule: nullify bash histories
RUN ln -sf /dev/null /root/.bash_history && \
    ln -sf /dev/null /home/mario/.bash_history

# Setup entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose HTTP port
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
