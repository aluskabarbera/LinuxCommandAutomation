#!/bin/bash
# Esta programa permite gestionar los grupos y usuarios en Linux

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

# Buscamos los usuarios existentes en el sistema y los guardamos en un string
usuarios=$(cut -d: -f1 /etc/passwd)

# Cada 80 caracteres del string se imprime una linea
usuarios=$(echo $usuarios | fold -w 80)

# Buscamos los grupos existentes en el sistema y los guardamos en un string
grupos=$(cut -d: -f1 /etc/group)

# Cada 80 caracteres del string se imprime una linea
grupos=$(echo $grupos | fold -w 80)

# Crearemos una función para mostrar los usuarios existentes
mostrar_usuarios () {
    echo -e " 
--------------------------------------------------------------------------------
\e[0;34mUsuarios existentes:\e[0m
--------------------------------------------------------------------------------
$usuarios
--------------------------------------------------------------------------------
"
}

# Crearemos una función para mostrar los grupos existentes
mostrar_grupos () {
    echo -e "
--------------------------------------------------------------------------------
\e[0;34mGrupos existentes:\e[0m
--------------------------------------------------------------------------------
$grupos
--------------------------------------------------------------------------------
"
}

# Creamos una función para comprobar si el usuario existe
comprobar_crear_usuario () {
    # Comprobamos que el usuario que queremos crear NO existe
    comprobar_existencia_usuario=$(cat /etc/passwd | cut -d: -f1 | grep -w $nombre_usuario)

    if [ -z "$comprobar_existencia_usuario" ]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mEl usuario\e[0m $nombre_usuario \e[0;32mno existe.\e[0m
--------------------------------------------------------------------------------
"
    else
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: El usuario\e[0m $nombre_usuario \e[0;31mexiste.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos una función para comprobar si el usuario existe
comprobar_eliminar_usuario () {
    # Comprobamos que el usuario que queremos borrar NO existe
    comprobar_existencia_usuario=$(cat /etc/passwd | cut -d: -f1 | grep -w $nombre_usuario)

    if [ -z "$comprobar_existencia_usuario" ]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: El usuario\e[0m $nombre_usuario \e[0;31mno existe.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    else
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mEl usuario\e[0m $nombre_usuario \e[0;32mexiste.\e[0m
--------------------------------------------------------------------------------
"
    fi
}

# Creamos una función para comprobar si el grupo existe
comprobar_crear_grupo () {
    # Comprobamos que el grupo que queremos crear NO existe
    comprobar_existencia_grupo=$(cat /etc/group | cut -d: -f1 | grep -w $nombre_grupo)

    if [ -z "$comprobar_existencia_grupo" ]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mEl grupo\e[0m $nombre_grupo \e[0;32mno existe.\e[0m
--------------------------------------------------------------------------------
"
    else
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: El grupo\e[0m $nombre_grupo \e[0;31mexiste.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    fi
}

# Creamos una función para comprobar si el grupo existe
comprobar_eliminar_grupo () {
    # Comprobamos que el grupo que queremos buscar NO existe
    comprobar_existencia_grupo=$(cat /etc/group | cut -d: -f1 | grep -w $nombre_grupo)

    if [ -z "$comprobar_existencia_grupo" ]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: El grupo\e[0m $nombre_grupo \e[0;31mno existe.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    else
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mEl grupo\e[0m $nombre_grupo \e[0;32mexiste.\e[0m
--------------------------------------------------------------------------------
"
    fi
}

# Creamos una función para crear un usuario
crear_usuario () {
    # Creamos el usuario
    useradd $nombre_usuario -m -d /home/$nombre_usuario -s /bin/bash > /dev/null 2>&1
    # Le preguntamos al usuario la contraseña
    passwd $nombre_usuario
}

# Creamos una función para crear un grupo
crear_grupo () {
    # Creamos el grupo
    groupadd $nombre_grupo
    # Mostramos el grupo creado
    echo -e "
--------------------------------------------------------------------------------
\e[0;32mGrupo\e[0m $nombre_grupo \e[0;32mha sido creado.\e[0m
--------------------------------------------------------------------------------
"
}

# Creamos una función para eliminar un usuario
eliminar_usuario () {
    # Eliminamos el usuario
    userdel -r $nombre_usuario > /dev/null 2>&1
    # Eliminamos el directorio del usuario
    rm -rf /home/$nombre_usuario
    # Mostramos el usuario eliminado
    echo -e "
--------------------------------------------------------------------------------
\e[0;32mUsuario\e[0m $nombre_usuario \e[0;32mha sido eliminado.\e[0m
--------------------------------------------------------------------------------
"
}

# Creamos una función para eliminar un grupo
eliminar_grupo () {
    # Eliminamos el grupo
    groupdel $nombre_grupo
    # Mostramos el grupo eliminado
    echo -e "
--------------------------------------------------------------------------------
\e[0;32mGrupo\e[0m $nombre_grupo \e[0;32mha sido eliminado.\e[0m
--------------------------------------------------------------------------------
"
}

# Creamos una función para añadir un usuario a un grupo
añadir_usuario_a_grupo () {
    # Le preguntamos al usuario si quiere añadir el usuario a un grupo
    read -p "¿Quieres añadir el usuario $nombre_usuario a un grupo existente? [s/n]: " respuesta
    if [[ $respuesta =~ ^[Ss]$ ]]; then
        # Mostramos los grupos existentes
        mostrar_grupos
        # Le preguntamos al usuario el nombre del grupo
        read -p "¿Cual es el nombre del grupo?: " nombre_grupo
        # Comprobamos que el grupo existe
        comprobar_eliminar_grupo
        # Añadimos el usuario al grupo
        useradd $nombre_usuario -g $nombre_grupo -m -d /home/$nombre_usuario -s /bin/bash
        # Mostramos el usuario añadido al grupo
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mUsuario\e[0m $nombre_usuario \e[0;32mha sido creado y añadido al grupo\e[0m $nombre_grupo\e[0;32m con el directorio\e[0m /home/$nombre_usuario 
\e[0;32my el shell\e[0m /bin/bash\e[0;32m.\e[0m
--------------------------------------------------------------------------------
"
    elif [[ $respuesta =~ ^[Nn]$ ]]; then
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mUsuario\e[0m $nombre_usuario \e[0;32mha sido creado con el directorio\e[0m /home/$nombre_usuario \e[0;32my el shell\e[0m /bin/bash\e[0;32m.\e[0m

\e[0;32mPor defecto se ha creado el grupo\e[0m $nombre_usuario \e[0;32mcon el usuario\e[0m $nombre_usuario \e[0;32mcomo miembro.\e[0m
--------------------------------------------------------------------------------
"
    else
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: Respuesta no válida.\e[0m
--------------------------------------------------------------------------------
"
        exit 1
    fi
}

# Definimos una función para mostrar el menú de gestión de grupos
menú_gestionar_grupos() {
    echo -e "
--------------------------------------------------------------------------------
\e[0;34mGestionar grupos\e[0m
--------------------------------------------------------------------------------
\e[0;31m[0] Salir\e[0m
[1] Crear grupo
[2] Borrar grupo
--------------------------------------------------------------------------------
"
read -p "Escoge una opción: " opcion
case $opcion in
    0)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mSaliendo del programa...\e[0m
--------------------------------------------------------------------------------
"
        ;;
    1)
        echo -e "
--------------------------------------------------------------------------------
\e[0;34mCrear grupo\e[0m
--------------------------------------------------------------------------------
"
        # Le mostramos los grupos existentes
        mostrar_grupos
        # Preguntamos al usuario por el nombre del grupo
        read -p "Nombre del grupo: " nombre_grupo
        # Comprobamos si el grupo existe
        comprobar_crear_grupo
        # Creamos el grupo
        crear_grupo
        ;;
    2)
        echo -e "
--------------------------------------------------------------------------------
\e[0;34mBorrar grupo\e[0m
--------------------------------------------------------------------------------
"
        # Le mostramos los grupos existentes
        mostrar_grupos
        # Preguntamos al usuario por el nombre del grupo
        read -p "Nombre del grupo: " nombre_grupo
        # Comprobamos si el grupo existe
        comprobar_eliminar_grupo
        # Eliminamos el grupo
        eliminar_grupo
        ;;
    *)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: Opción incorrecta\e[0m
--------------------------------------------------------------------------------
"
        ;;
esac
}

# Definimos una función para mostrar el menú de gestión de usuarios
menú_gestionar_usuarios() {
    echo -e "
--------------------------------------------------------------------------------
\e[0;34mGestionar usuarios\e[0m
--------------------------------------------------------------------------------
\e[0;31m[0] Salir\e[0m
[1] Crear usuario
[2] Borrar usuario
[3] Añadir usuario a grupo
--------------------------------------------------------------------------------
"
read -p "Escoge una opción: " opcion
case $opcion in
    0)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mSaliendo del programa...\e[0m
--------------------------------------------------------------------------------
"
        ;;
    1)
        echo -e "
--------------------------------------------------------------------------------
\e[0;34mCrear usuarios\e[0m
--------------------------------------------------------------------------------
"
        # Le mostramos los usuarios existentes
        mostrar_usuarios
        # Preguntamos al usuario por el nombre del usuario
        read -p "Nombre del usuario: " nombre_usuario
        # Comprobamos si el usuario existe
        comprobar_crear_usuario
        # Añadimos el usuario a un grupo
        añadir_usuario_a_grupo
        # Creamos el usuario
        crear_usuario
        ;;
    2)
        echo -e "
--------------------------------------------------------------------------------
\e[0;34mBorrar usuarios\e[0m
--------------------------------------------------------------------------------
"
        # Le mostramos los usuarios existentes
        mostrar_usuarios
        # Preguntamos al usuario por el nombre del usuario
        read -p "Nombre del usuario: " nombre_usuario
        # Comprobamos si el usuario existe
        comprobar_eliminar_usuario
        # Eliminamos el usuario
        eliminar_usuario
        ;;
    3)
        echo -e "
--------------------------------------------------------------------------------
\e[0;34mAñadir usuario a grupo\e[0m
--------------------------------------------------------------------------------
"
        # Le mostramos los usuarios existentes
        mostrar_usuarios
        # Preguntamos al usuario por el nombre del usuario
        read -p "Nombre del usuario: " nombre_usuario
        # Comprobamos si el usuario existe
        comprobar_eliminar_usuario
        # Le mostramos los grupos existentes
        mostrar_grupos
        # Preguntamos al usuario por el nombre del grupo
        read -p "Nombre del grupo: " nombre_grupo
        # Comprobamos si el grupo existe
        comprobar_eliminar_grupo
        # Añadimos el usuario al grupo
        usermod -a -G $nombre_grupo $nombre_usuario
        echo -e "
--------------------------------------------------------------------------------
\e[0;32mUsuario\e[0m $nombre_usuario \e[0;32mha sido añadido al grupo\e[0m $nombre_grupo
--------------------------------------------------------------------------------
"
        ;;
    *)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: Opción incorrecta\e[0m
--------------------------------------------------------------------------------
"
        ;;
esac
}

# Creamos un menú para gestionar los grupos y usuarios
echo -e "
--------------------------------------------------------------------------------
\e[0;34mGestionar grupos y usuarios\e[0m
--------------------------------------------------------------------------------
\e[0;31m[0] Salir\e[0m
[1] Gestionar grupos
[2] Gestionar usuarios
--------------------------------------------------------------------------------
"
read -p "Escoge una opción: " opcion
case $opcion in
    0)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mSaliendo del programa...\e[0m
--------------------------------------------------------------------------------
"
        ;;
    1)
        menú_gestionar_grupos
        ;;
    2)
        menú_gestionar_usuarios
        ;;
    *)
        echo -e "
--------------------------------------------------------------------------------
\e[0;31mError: Opción incorrecta\e[0m
--------------------------------------------------------------------------------
"
        ;;
esac

# A!ÜSKA
