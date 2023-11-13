# Practica-01-06-iaw
## En esta práctica vamos a instalar wordpress en una instancia EC2 de AWS.
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
#### Install_lamp
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