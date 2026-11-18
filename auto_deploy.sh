#!/bin/bash

# ==============================================================================
# Dockerlabs Auto Deploy Script - php2shell
# Dificultad: Media
# Vulnerabilidad: PHP2Shell (CVE-2026-109618 / CVE-2026-109619)
# ==============================================================================

# Colores de la terminal
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

CONTAINER_NAME="php2shell"
IMAGE_NAME="dockerlabs/php2shell"
NETWORK_NAME="dockerlabs_net"
SUBNET="172.18.0.0/16"
TARGET_IP="172.18.0.2"

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Detectada señal de interrupción (Ctrl+C). Deteniendo laboratorio...${endColour}"
    docker stop ${CONTAINER_NAME} >/dev/null 2>&1
    docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1
    echo -e "${greenColour}[+] Contenedor eliminado exitosamente.${endColour}"
    echo -e "${yellowColour}[*] Recuerda eliminar la entrada de /etc/hosts si ya no la necesitas.${endColour}\n"
    exit 0
}

trap ctrl_c INT

# Comprobar privilegios de root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n${redColour}[!] Este script debe ejecutarse como root o con sudo.${endColour}\n"
    echo -e "${yellowColour}[*] Ejemplo: sudo bash auto_deploy.sh${endColour}\n"
    exit 1
fi

clear
echo -e "${turquoiseColour}"
cat << "EOF"
  ____             _             _       _           
 |  _ \  ___   ___| | _____ _ __| | __ _| |__  ___   
 | | | |/ _ \ / __| |/ / _ \ '__| |/ _` | '_ \/ __|  
 | |_| | (_) | (__|   <  __/ |  | | (_| | |_) \__ \  
 |____/ \___/ \___|_|\_\___|_|  |_|\__,_|_.__/|___/  
                                    php2shell.dl
EOF
echo -e "${endColour}"
echo -e "${purpleColour}======================================================================${endColour}"
echo -e "${blueColour}[*] Máquina:${endColour} ${grayColour}PHP2Shell (DockerLabs)${endColour}"
echo -e "${blueColour}[*] Dificultad:${endColour} ${yellowColour}Media${endColour}"
echo -e "${blueColour}[*] CVEs:${endColour} ${redColour}CVE-2026-109618 / CVE-2026-109619 (PHP2Shell)${endColour}"
echo -e "${purpleColour}======================================================================${endColour}\n"

# 1. Limpiar contenedor previo si existe
docker stop ${CONTAINER_NAME} >/dev/null 2>&1
docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1

# 2. Comprobar y configurar red docker
echo -e "${blueColour}[*] Configurando red Docker (${NETWORK_NAME})...${endColour}"
if ! docker network ls --format '{{.Name}}' | grep -wq "${NETWORK_NAME}"; then
    docker network create --subnet=${SUBNET} ${NETWORK_NAME} >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        # En caso de colisión de subred en el host
        docker network create ${NETWORK_NAME} >/dev/null 2>&1
    fi
fi

# 3. Compilar imagen
echo -e "${blueColour}[*] Construyendo la imagen del laboratorio (${IMAGE_NAME})...${endColour}"
BUILD_OUT=$(docker build -t ${IMAGE_NAME} . 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${redColour}[-] Error al construir la imagen Docker:${endColour}"
    echo -e "${yellowColour}${BUILD_OUT}${endColour}"
    exit 1
fi

# 4. Desplegar contenedor con IP estática en la red dockerlabs
echo -e "${blueColour}[*] Levantando el contenedor con IP ${TARGET_IP}...${endColour}"
RUN_OUT=$(docker run -dit --name ${CONTAINER_NAME} \
    --net ${NETWORK_NAME} \
    --ip ${TARGET_IP} \
    ${IMAGE_NAME} 2>&1)

if [ $? -ne 0 ]; then
    # Intento de rescate si la IP estática choca o la subred es dinámica
    RUN_OUT=$(docker run -dit --name ${CONTAINER_NAME} \
        --net ${NETWORK_NAME} \
        ${IMAGE_NAME} 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${redColour}[-] Error al iniciar el contenedor:${endColour}"
        echo -e "${yellowColour}${RUN_OUT}${endColour}"
        exit 1
    fi
    # Obtener IP asignada dinámicamente
    TARGET_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_NAME})
fi

# 5. Configuración de /etc/hosts (dockerlabs convention: .dl domain)
DOMAIN="php2shell.dl"
sed -i "/${DOMAIN}/d" /etc/hosts 2>/dev/null
echo "${TARGET_IP} ${DOMAIN}" >> /etc/hosts
echo -e "${yellowColour}[!] Asignado en /etc/hosts: ${TARGET_IP} ${DOMAIN}${endColour}"

echo -e "\n${greenColour}[✓] ¡Laboratorio desplegado exitosamente!${endColour}\n"
echo -e "  ${turquoiseColour}➤ Dirección IP:${endColour}  ${greenColour}${TARGET_IP}${endColour}"
echo -e "  ${turquoiseColour}➤ Dominio local:${endColour} ${yellowColour}http://${DOMAIN}${endColour}"
echo -e "  ${turquoiseColour}➤ Exploit PoC:${endColour}   ${grayColour}exploit/exploit_php2shell.py${endColour}\n"
echo -e "${yellowColour}[*] Presiona Ctrl+C en cualquier momento para apagar y limpiar el laboratorio.${endColour}\n"

# Mantener en ejecución hasta Ctrl+C
while true; do
    sleep 2
done
