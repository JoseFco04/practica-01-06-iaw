# Practica-01-06-iaw
## En esta práctica vamos a instalar wordpress en una instancia EC2 de AWS.
## La máquina de Amazon se va a ver de la siguiente manera.Con las siguientes características:
![Cap maquina ](https://github.com/JoseFco04/practica-01-06-iaw/assets/145347148/72b3a9b2-4125-44f5-858d-e6bcf9992b41)

### Para ello primero creamos un script para instalar wordpress en un directorio raiz, que es el siguiente paso a paso:

#### Muestra todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
#### Elminamos descargas previas del código fuente
~~~
rm -rf /tmp/latest.zip
~~~
#### Descargamos el código fuente
~~~
wget https://wordpress.org/latest.zip -P /tmp
~~~
#### Instalamos el comando unzip
~~~
apt install unzip -y
~~~
#### Descomprimimos el archivo latest.zip
~~~
unzip -u /tmp/latest.zip -d /tmp
~~~
#### Eliminamos instalaciones previas de WordPress en /var/www/html
~~~
rm -rf /var/www/html/*
~~~
#### Movemos el contenido de /tmp/wordpress a /var/www/html
~~~
mv -f /tmp/wordpress/* /var/www/html
~~~
#### Creamos la base de datos y el usuario para WordPress
~~~
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
~~~
#### Creamos nuestro archivo de configuración de WordPress
~~~
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
~~~
#### Configuramos las variables del archivo de configuración de WordPress
~~~
sed -i "s/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
~~~
#### Cambiamos el propietario y el grupo del directorio /var/www/html
~~~
chown -R www-data:www-data /var/www/html/
~~~
### Después hacemos otro script muy parecido al anterior pero ahora lo instalamos en su propio directorio. Para ello usamos estes script paso por paso:

#### Muestra todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
#### Elminamos descargas previas del código fuente
~~~
rm -rf /tmp/latest.zip
~~~
#### Descargamos la ultima version del wordpress con el wget
~~~
wget http://wordpress.org/latest.zip -P /tmp
~~~
#### Instalamos el unzip 
~~~
apt install unzip -y 
~~~
#### Descomprimimos el archivo que acabamos de descargar con el comando tar
~~~
unzip -u /tmp/latest.zip -d /tmp
~~~
#### Eliminamos instalaciones previas de WordPress en /var/www/html
~~~
rm -rf /var/www/html/*
~~~
#### Movemos el contenido de /tmp/wordpress a /var/www/html
~~~
mv -f /tmp/wordpress/ /var/www/html
~~~
#### Creamos la base de datos y el usuario para WordPress
~~~
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
~~~
#### Creamos el archivo de configuracion a partir del archivo de ejemplo
~~~
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
~~~
#### Remplazamos el texto por los valores de las variables
~~~
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wordpress/wp-config.php
~~~
#### Automatizamos la configuracion de las variables wp_siteurl y wp_home
~~~
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CB_DOMAIN/wordpress');" /var/www/html/wordpress/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CB_DOMAIN');" /var/www/html/wordpress/wp-config.php
~~~
#### Cambiamos el propietario y el grupo del directorio /var/www/html
~~~
chown -R www-data:www-data /var/www/html/
~~~
#### Copiamos el archivo /var/www/html/wordpress/index.php a /var/www/html
~~~
cp /var/www/html/wordpress/index.php /var/www/html
~~~
#### Editamos el archivo index.php
~~~
sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php
~~~
### En este paso perparamos la configuración para los enlaces permanentes creando el archivoo .htaccess en el directorio /var/www/html.El archivo debe verse así
~~~
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
~~~
#### Copiamos el nuevo archivo .htaccess 
~~~
cp ../htaccess/.htaccess /var/www/html
~~~
#### Habilitamos el módulo mod_rewrite de Apache
~~~
a2enmod rewrite
~~~
#### Reiniciamos el servicio de apache2
~~~
systemctl restart apache2
~~~
### A parte de crear estos archivos para que vaya bien tenemos que ejecutar tambien scripts de prácticas anteriores : el install_lamp, el .env, el letsencrypt , el php y el 000-default-config. Para recordarlo los dejo por aquí paso por paso:
### Install_lamp
#### Muestra todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
apt upgrade -y
~~~
#### Instalamos el servidor web Apache
~~~
sudo apt install apache2 -y
~~~
#### Instalamos el gestor de bases de datos MySQL
~~~
sudo apt install mysql-server -y
~~~
#### Instalamos PHP
~~~
apt install php libapache2-mod-php php-mysql -y
~~~
#### Copiamos el archivo conf de apache 
~~~
cp ../conf/000-default.conf /etc/apache2/sites-available
~~~
#### Reiniciamos el servicio de Apache
~~~
systemctl restart apache2
~~~
#### Copiamos el archivo de php
~~~ 
cp ../php/index.php /var/www/html
~~~
#### Modificamos el propietario y el grupo del directorio /var/www/html
~~~
chown -R www-data:www-data /var/www/html
~~~
### El .env se ve así:
#### Configuramos las variables
~~~
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=josefco
WORDPRESS_DB_PASSWORD=1234
WORDPRESS_DB_HOST=localhost
WORDPRESS_SITEURL=http://practica6-jose.ddns.net
WORDPRESS_HOME=josefco-taller.com
WORDPRESS_COLLATE=''

IP_CLIENTE_MYSQL=localhost

CB_MAIL=josefco@iaw.com
CB_DOMAIN=practica6-jose.ddns.net
~~~
### El script del let´s encrypt se va a ver así:
#### Muestra todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
#apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
#### Instalamos y actualizamos snapd
~~~
snap install core && snap refresh core
~~~
#### Eliminamos cualquier instalación previa de certbot con apt
~~~
apt remove certbot
~~~
#### Instalamos la aplicación certbot
~~~
snap install --classic certbot
~~~
#### Creamos un alias para la aplicación certbot
~~~
ln -fs /snap/bin/certbot /usr/bin/certbot
~~~
#### Ejecutamos el comando certbot
~~~
certbot --apache -m $CB_MAIL --agree-tos --no-eff-email -d $CB_DOMAIN --non-interactive
~~~
### El archivo de configuración de php :
~~~
<?php

phpinfo();

?>
~~~
### El 000-default-config se verá así 
~~~
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
  #ServerName www.example.com
  DocumentRoot /var/www/html
  DirectoryIndex index.php index.html

  <Directory "/var/www/html">
    AllowOverride All
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
~~~
### Una vez ejecutados todos los scripts si buscamos nuestro dominio en el buscaador nos saldrá para hacer la configuración de nuestro wordpress adjunto un par de capturas de como nos queda el wordpress:
![cap info wordpress](https://github.com/JoseFco04/practica-01-06-iaw/assets/145347148/120383a6-9407-425c-a3b6-b628254cc03c)

### Así se ve cuando enttras a wordpress:
![cap dentro](https://github.com/JoseFco04/practica-01-06-iaw/assets/145347148/77c4f7ee-fc2d-49bc-a3b0-02eb59455696)
