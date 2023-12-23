#!/bin/bash
# Este programa permite gestionar las interfaces de red en Linux

# Creamos una función para comprobar si el usuario es root o no.
es_root () {
    if [ "$(id -u)" != "0" ]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: Este script debe ser ejecutado con permisos de\e[0m root\e[0;31m.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    fi
}

es_root

# Buscamos las interfaces de red que tiene disponibles
interfaces_disponibles=$(ls /sys/class/net/)

# Buscamos todas las IPs de las interfazes de red
ips_disponibles=$(ip addr show | grep "inet " | cut -d " " -f 6)

# Buscamos las interfaces de red que están activas
interfaces_activas=$(ip a | grep "state UP" | cut -d ":" -f 2 | awk '{print $1}')

# Buscamos las interfaces de red que están desactivadas
interfaces_desactivadas=$(ip a | grep "state DOWN" | cut -d ":" -f 2 | awk '{print $1}')


interfaces_IPs_exitentes () {
    # Buscamos las interfaces de red que están activas
    interfaces_activas=$(ip a | grep "state UP" | cut -d ":" -f 2 | awk '{print $1}')

    # Le mostramos al usuario las interfaces de red que están activas con su IP asignada.
    echo -e "
----------------------------------------------------------------------------------
\e[0;32mInterfaces de red activas y sus correspondientes IPs.\e[0m
----------------------------------------------------------------------------------
"
    for interface in $interfaces_activas; do
        echo "$interface : $(ip a | grep "inet " | grep $interface | awk '{print $2}')" 
    done
    echo "
----------------------------------------------------------------------------------
"
}

# Mostramos las interfaces de red.
echo -e "
----------------------------------------------------------------------------------
\e[0;34mTienes las siguientes interfaces de red disponibles:\e[0m
----------------------------------------------------------------------------------
"$interfaces_disponibles"             
----------------------------------------------------------------------------------
\e[0;31mTienes las siguientes interfaces de red desactivadas:\e[0m
----------------------------------------------------------------------------------
"$interfaces_desactivadas"
----------------------------------------------------------------------------------
"
interfaces_IPs_exitentes

echo -e "
----------------------------------------------------------------------------------
\e[0;34mActivar o desactivar interfaces de red\e[0m
----------------------------------------------------------------------------------
\e[0;31m[0] Salir\e[0m
[1] Activar interfaces de red
[2] Desactivar interfaces de red
----------------------------------------------------------------------------------
"

read -p "Selecciona una opción: " opcion

case $opcion in
    0)
        echo -e "
----------------------------------------------------------------------------------
\e[0;31mSaliendo del programa...\e[0m
----------------------------------------------------------------------------------
"
        exit 0
        ;;
    1)
        clear
        echo -e "
----------------------------------------------------------------------------------
\e[0;34mActivando interfaces de red\e[0m
----------------------------------------------------------------------------------
\e[0;31mTienes las siguientes interfaces de red desactivadas:\e[0m
----------------------------------------------------------------------------------
"$interfaces_desactivadas"
----------------------------------------------------------------------------------
"
        read -p "Introduce el nombre de la interfaz de red que quieres activar: " interfaz
        # Comprobamos que la interfaz de red que queremos activar existe
        comprobar_existencia_interfaz=$(echo $interfaces_desactivadas | grep $interfaz)
        if [ -z "$comprobar_existencia_interfaz" ]; then
            echo -e "
----------------------------------------------------------------------------------
\e[0;31mError: La interfaz de red que has introducido NO existe o ya esta activada.\e[0m
----------------------------------------------------------------------------------
"
            exit 1
        fi
        # Si la interfaz de red existe, la activamos
        ip link set $interfaz up

        # Comprobamos que la interfaz de red se ha activado correctamente
        comprobar_activacion_interfaz=$(ip a | grep "state UP" | cut -d ":" -f 2 | awk '{print $1}' | grep $interfaz)
        if [ -z "$comprobar_activacion_interfaz" ]; then
            echo -e "
----------------------------------------------------------------------------------
\e[0;31mError: La interfaz de red que has introducido NO se ha activado correctamente.\e[0m
----------------------------------------------------------------------------------
"
            exit 1
        fi
        # Buscamos las interfaces de red que tiene disponibles
        interfaces_disponibles=$(ls /sys/class/net/)

        # Buscamos las interfaces de red que están activas
        interfaces_activas=$(ip a | grep "state UP" | cut -d ":" -f 2 | awk '{print $1}')

        # Buscamos las interfaces de red que están desactivadas
        interfaces_desactivadas=$(ip a | grep "state DOWN" | cut -d ":" -f 2 | awk '{print $1}')
        # Mostramos las interfaces de red.
        echo -e "
----------------------------------------------------------------------------------
\e[0;34mTienes las siguientes interfaces de red disponibles:\e[0m
----------------------------------------------------------------------------------
"$interfaces_disponibles"             
----------------------------------------------------------------------------------
\e[0;31mTienes las siguientes interfaces de red desactivadas:\e[0m
----------------------------------------------------------------------------------
"$interfaces_desactivadas"
----------------------------------------------------------------------------------
"
        interfaces_IPs_exitentes
        ;;
    2)
        clear
        echo -e "
----------------------------------------------------------------------------------
\e[0;34mDesactivando interfaces de red\e[0m
----------------------------------------------------------------------------------
"
        interfaces_IPs_exitentes
        read -p "Introduce el nombre de la interfaz de red que quieres desactivar: " interfaz
        # Comprobamos que la interfaz de red que queremos desactivar existe
        comprobar_existencia_interfaz=$(echo $interfaces_activas | grep $interfaz)
        if [ -z "$comprobar_existencia_interfaz" ]; then
            echo -e "
----------------------------------------------------------------------------------
\e[0;31mError: La interfaz de red que has introducido NO existe o ya esta desactivada.\e[0m
----------------------------------------------------------------------------------
"
            exit 1
        fi
        # Si la interfaz de red existe, la desactivamos
        ip link set $interfaz down

        # Comprobamos que la interfaz de red se ha desactivado
        comprobar_desactivacion_interfaz=$(ip a | grep "state DOWN" | cut -d ":" -f 2 | awk '{print $1}' | grep $interfaz)
        if [ -z "$comprobar_desactivacion_interfaz" ]; then
            echo -e "
----------------------------------------------------------------------------------
\e[0;31mError: La interfaz de red que has introducido NO se ha desactivado.\e[0m
----------------------------------------------------------------------------------
"
            exit 1
        fi
        # Buscamos las interfaces de red que tiene disponibles
        interfaces_disponibles=$(ls /sys/class/net/)

        # Buscamos las interfaces de red que están activas
        interfaces_activas=$(ip a | grep "state UP" | cut -d ":" -f 2 | awk '{print $1}')

        # Buscamos las interfaces de red que están desactivadas
        interfaces_desactivadas=$(ip a | grep "state DOWN" | cut -d ":" -f 2 | awk '{print $1}')
        # Mostramos las interfaces de red.
        echo -e "
----------------------------------------------------------------------------------
\e[0;34mTienes las siguientes interfaces de red disponibles:\e[0m
----------------------------------------------------------------------------------
"$interfaces_disponibles"             
----------------------------------------------------------------------------------
\e[0;31mTienes las siguientes interfaces de red desactivadas:\e[0m
----------------------------------------------------------------------------------
"$interfaces_desactivadas"
----------------------------------------------------------------------------------
"
        interfaces_IPs_exitentes
        ;;
    *)
        echo -e "
----------------------------------------------------------------------------------
\e[0;31mError: Opción incorrecta\e[0m
----------------------------------------------------------------------------------
"
        ;;
esac

# A!ÜSKA
