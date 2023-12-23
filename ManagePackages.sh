#!/bin/bash
# Este script servirá para instalar, actualizar o desinstalar todos los programas que necesita el usuario.

# Creamos una función para comprobar si el usuario es root o no.
es_root () {
    if [ "$(id -u)" != "0" ]; then
        echo -e "
------------------------------------------------------------------------------
\e[0;31mError: Este script debe ser ejecutado con permisos de\e[0m root\e[0;31m.\e[0m
------------------------------------------------------------------------------
"
        exit 1
    fi
}

es_root

# Creamos una función para comprobar si el comando anterior se ha ejecutado correctamente.
comando_ejecutado () {
    if [ $? -eq 0 ]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mEl comando se ha ejecutado correctamente.\e[0m
-----------------------------------------------------------------------------
"
    else
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mEl comando no se ha ejecutado correctamente.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos una función para comprobar si el usuario tiene instalados los paquetes para saber si debemos instalarlos.
comprobar_paquete_instalar () {
    # Comprobamos si el usuario tiene instalado el paquete con el comando whereis.
    paquete_a_instalar_instalado=$(whereis $paquete_a_instalar | awk '{print $2}')

    if [ -z "$paquete_a_instalar_instalado" ]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mNo se ha encontrado el paquete\e[0m $paquete_a_instalar\e[0;31m.\e[0m
-----------------------------------------------------------------------------
"
    else 
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mEl paquete\e[0m $paquete_a_instalar\e[0;32m se ha encontrado.\e[0m
-----------------------------------------------------------------------------
"
    exit 1
    fi
}

# Creamos una función para comprobar si el usuario tiene instalados los paquetes para saber si debemos desinstalarlos.
comprobar_paquete_desinstalar () {
    # Comprobamos si el usuario tiene instalado el paquete con el comando whereis.
    paquete_a_instalar_instalado=$(whereis $paquete_a_instalar | awk '{print $2}')

    if [ -z "$paquete_a_instalar_instalado" ]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mNo se ha encontrado el paquete\e[0m $paquete_a_instalar\e[0;31m.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    else 
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mEl paquete\e[0m $paquete_a_instalar\e[0;32m se ha encontrado.\e[0m
-----------------------------------------------------------------------------
"
    fi
}

# Creamos una función para comprobar si el usuario desea instalar el paquete.
instalar_paquete () {
    echo -e "
-----------------------------------------------------------------------------
\e[0;34m¿Desea instalar el paquete\e[0m $paquete_a_instalar\e[0;34m?\e[0m
-----------------------------------------------------------------------------
"
    read -p "[s/n]: " respuesta

    if [[ $respuesta =~ ^[Ss]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mInstalando el paquete\e[0m $paquete_a_instalar\e[0;32m...\e[0m
-----------------------------------------------------------------------------
"
        apt-get install $paquete_a_instalar -y
    elif [[ $respuesta =~ ^[Nn]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mNo se instalará el paquete\e[0m $paquete_a_instalar\e[0;31m.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    else
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mError: Respuesta no válida.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos una función para comprobar si el usuario desea desinstalar el paquete.
desinstalar_paquete () {
    echo -e "
-----------------------------------------------------------------------------
\e[0;34m¿Desea desinstalar el paquete\e[0m $paquete_a_instalar\e[0;34m?\e[0m
-----------------------------------------------------------------------------
"
    read -p "[s/n]: " respuesta

    if [[ $respuesta =~ ^[Ss]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mDesinstalando el paquete\e[0m $paquete_a_instalar\e[0;32m...\e[0m
-----------------------------------------------------------------------------
"
        apt-get remove $paquete_a_instalar -y
        apt-get purge $paquete_a_instalar -y
        apt-get update
        apt-get autoremove -y
    elif [[ $respuesta =~ ^[Nn]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mNo se desinstalará el paquete\e[0m $paquete_a_instalar\e[0;31m.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    else
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mError: Respuesta no válida.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos una función para comprobar si el usuario desea actualizar los paquetes del sistema.
actualizar_paquete () {
    read -p "¿Desea actualizar los paquetes del sistema? [s/n]: " respuesta

    if [[ $respuesta =~ ^[Ss]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;32mActualizando paquetes del sistema...\e[0m
-----------------------------------------------------------------------------
"
        apt-get update
        apt-get upgrade -y
    elif [[ $respuesta =~ ^[Nn]$ ]]; then
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mNo se actualizarán los paquetes del sistema.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    else
        echo -e "
-----------------------------------------------------------------------------
\e[0;31mError: Respuesta no válida.\e[0m
-----------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos un menu para elegir la opción que desea realizar.
echo -e "
------------------------------------------------------------------------------
\e[0;34mGestor de paquetes\e[0m
------------------------------------------------------------------------------
\e[0;31m[0] Salir\e[0m
[1] Instalar paquetes
[2] Desinstalar paquetes
[3] Actualizar paquetes del sistema
------------------------------------------------------------------------------
"
read -p "Elige una opción: " opcion

case $opcion in
    0)
        echo -e "
------------------------------------------------------------------------------
\e[0;31mSaliendo del programa...\e[0m
------------------------------------------------------------------------------
"
        exit 0
        ;;
    1)
        echo -e "
------------------------------------------------------------------------------
\e[0;34mInstalar paquetes\e[0m
------------------------------------------------------------------------------
"
        read -p "Introduce el nombre del paquete: " paquete_a_instalar
        comprobar_paquete_instalar
        instalar_paquete
        comando_ejecutado
        ;;
    2)
        echo -e "
------------------------------------------------------------------------------
\e[0;34mDesinstalar paquetes\e[0m
------------------------------------------------------------------------------
"
        read -p "Introduce el nombre del paquete: " paquete_a_instalar
        comprobar_paquete_desinstalar
        desinstalar_paquete
        comando_ejecutado
        ;;
    3)
        echo -e "
------------------------------------------------------------------------------
\e[0;34mActualizar paquetes\e[0m
------------------------------------------------------------------------------
"
        actualizar_paquete
        comando_ejecutado
        ;;
    *)
        echo -e "
------------------------------------------------------------------------------
\e[0;31mError: Opción incorrecta\e[0m
------------------------------------------------------------------------------
"
        exit 1
        ;;
esac

# A!Ü$KA
