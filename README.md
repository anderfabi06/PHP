# Máquina DockerLabs: PHP2Shell

![DockerLabs](https://img.shields.io/badge/Platform-DockerLabs-blue)
![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow)
![Category](https://img.shields.io/badge/Category-Web%20%2F%20Privilege%20Escalation-red)

Laboratorio vulnerable diseñado para la plataforma **DockerLabs.es** enfocado en enumeración web, aprovechamiento de un puente de depuración heredado (*legacy debug bridge*), análisis de configuraciones internas y escalada de privilegios a través de tareas programadas del sistema.

---

## 📋 Ficha Técnica

* **Nombre de la máquina:** `php2shell`
* **Dificultad:** Media
* **Sistema Operativo:** Ubuntu 22.04 LTS (x86_64)
* **Dominio asignado:** `php2shell.dl`
* **Vector Inicial:** Uso del puente de depuración heredado autenticado vía token de instancia en `api.php`.
* **Movimiento Lateral:** Reutilización de credencial descubierta en configuración interna de base de datos (`config_db.php`).
* **Escalada de Privilegios:** Modificación de script de mantenimiento (`/opt/backup/rotate.sh`) ejecutado periódicamente por `root` mediante `cron`.
* **Flags:**
  * **Intermedia:** `/opt/backup/notes.txt`
  * **User:** `/home/mario/user.txt`
  * **Root:** `/root/root.txt`

---

## 🚀 Despliegue Local

Para levantar el entorno vulnerable de forma automática, ejecuta con privilegios de administrador:

```bash
sudo bash auto_deploy.sh
```

El script configurará la red Docker, levantará el contenedor, asignará dinámicamente la entrada en `/etc/hosts` hacia `php2shell.dl` y mostrará los datos de acceso.

Para detener y limpiar el laboratorio, presiona `Ctrl+C` en la misma terminal.

---

## 📦 Empaquetado para Envío a DockerLabs

Para distribuir la máquina a la plataforma, excluye la solución y empaqueta el contenido esencial:

```bash
tar -czvf php2shell.tar.gz Dockerfile auto_deploy.sh entrypoint.sh config/ html/ README.md
```

La guía completa de resolución paso a paso se encuentra documentada en [writeup.md](writeup.md).
