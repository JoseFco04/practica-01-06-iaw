#!/bin/bash

# Muestra todos los comandos que se van ejecutando
set -ex

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes
#apt upgrade -y

# Importamos el archivo de variables .env
source .env

# Elminamos descargas previas del código fuente
rm -rf /tmp/latest.zip

# Descargamos el código fuente
wget https://wordpress.org/latest.zip -P /tmp

# Instalamos el comando unzip
apt install unzip -y

# Descomprimimos el archivo latest.zip
unzip -u /tmp/latest.zip -d /tmp

# Eliminamos instalaciones previas de WordPress en /var/www/html
rm -rf /var/www/html/*

# Movemos el contenido de /tmp/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html

# Creamos la base de datos y el usuario para WordPress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Creamos nuestro archivo de configuración de WordPress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configuramos las variables del archivo de configuración de WordPress
sed -i "s/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

# Cambiamos el propietario y el grupo del directorio /var/www/html
chown -R www-data:www-data /var/www/html/

