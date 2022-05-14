# Configure local environment settings
KNISHIO_SECRET=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w ${1:-2048} | head -n 1)
KNISHIO_HOST=knishnode.local
KNISHIO_DB_USERNAME=knishio
KNISHIO_DB_PASSWORD=knishio
KNISHIO_DB=knishio

cat << EOF
                       (
                      (/(
                      (//(
                      (///(
                     (/////(
                     (//////(                          )
                    (////////(                        (/)
                    (////////(                       (///)
                   (//////////(                      (////)
                   (//////////(                     (//////)
                  (////////////(                    (///////)
                 (/////////////(                   (/////////)
                (//////////////(                  (///////////)
                (///////////////(                (/////////////)
               (////////////////(               (//////////////)
              (((((((((((((((((((              (((((((((((((((
             (((((((((((((((((((              ((((((((((((((
             (((((((((((((((((((            ((((((((((((((
            ((((((((((((((((((((           (((((((((((((
            ((((((((((((((((((((          ((((((((((((
            (((((((((((((((((((         ((((((((((((
            (((((((((((((((((((        ((((((((((
            ((((((((((((((((((/      (((((((((
            ((((((((((((((((((     ((((((((
            (((((((((((((((((    (((((((
           ((((((((((((((((((  (((((
           #################  ##
           ################  #
          ################# ##
         %################  ###
         ###############(   ####
        ###############      ####
       ###############       ######
      %#############(        (#######
     %#############           #########
    ############(              ##########
   ###########                  #############
  #########                      ##############
%######

Powered by Knish.IO: Connecting a Decentralized World

------STOP!------

This script will install all necessary libraries to deploy a Knish.IO Laravel Reference Server. It will make changes to your operating system environment and packages.

By continuing, you accept responsibility for any and all consequences of this action.

Please inspect the source code of this script before continuing.

Sincerely,

WishKnish Team
https://knish.io

-----STOP!------
EOF

read -p "Are you sure you wish to continue? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Install PHP and Nginx
sudo apt install -y git curl
curl https://packages.sury.org/php/apt.gpg | sudo tee /usr/share/keyrings/suryphp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/suryphp-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
sudo apt update
sudo apt upgrade -y
sudo apt remove apache2
sudo apt install -y php8.1 php8.1-fpm php8.1-dom php8.1-redis php8.1-curl php8.1-mbstring php8.1-mysql php8.1-bcmath mariadb-server redis nginx

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

# Clone Knish.IO repository
git clone https://github.com/WishKnish/KnishIO-Server-Reference-Laravel.git
cd "KnishIO-Server-Reference-Laravel"
# Download dependencies
composer install

# Set up database and user
sudo mysql -uroot -p -e"CREATE DATABASE $KNISHIO_DB"
sudo mysql -uroot -p -e"GRANT ALL PRIVILEGES ON $KNISHIO_DB.* TO $KNISHIO_DB_USERNAME@localhost IDENTIFIED BY \"$KNISHIO_DB_PASSWORD\""
sudo mysql -uroot -p -e"FLUSH PRIVILEGES"

cat >.env <<-EOM
# This file helps you configure a new install of the KnishIO Server.
# See https://laravel.com/docs/master/configuration for instructions
# for working with the Laravel / Lumen .env files

# (optional) If you want the node to be able to sign transactions
# as a user and respond to T and A isotopes, enter its secret below:
SECRET_TOKEN_KNISH=$KNISHIO_SECRET

# (required) Basic environment configuration
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_LOG=daily
APP_LOG_LEVEL=debug
APP_DOMAIN=$KNISHIO_HOST
SESSION_DOMAIN=$KNISHIO_HOST
APP_URL=http://$KNISHIO_HOST
DIRECTORY_SEPARATOR=/

# (required) Database configuration
DB_HOST=127.0.0.1
DB_DATABASE=$KNISHIO_DB

# Uncomment below to use MySQL
DB_CONNECTION=mysql
DB_PORT=3306
DB_USERNAME=$KNISHIO_DB_USERNAME
DB_PASSWORD=$KNISHIO_DB_PASSWORD

QUEUE_CONNECTION=database
QUEUE_TABLE=knishio_jobs
QUEUE_FAILED_TABLE=knishio_failed_jobs

# Redis configuration
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

KNISHIO_PEERING=true
KNISHIO_PEERING_LOG=true
ACCESS_TOKEN=true
ACCESS_TOKEN_EXPIRATION=3600
ENABLE_ENCRYPTION=false
CONTINUID_ENABLED=false
EOM

php artisan key:generate

# Migrate database
php artisan migrate

# Configure web server
sudo tee /etc/nginx/sites-enabled/default <<EOF
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /var/www/html/public;
	index index.php index.html index.htm;
	server_name _;
	location / {
	    try_files \$uri \$uri/ /index.php?\$query_string;
	}
	location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOF
sudo /etc/init.d/nginx restart

# Modify hosts file
echo "127.0.0.1 $KNISHIO_HOST" | sudo tee -a /etc/hosts

# Move web content
cd ..
sudo rm -rf /var/www/html
sudo mv KnishIO-Server-Reference-Laravel /var/www/html
sudo chown -R www-data:www-data /var/www/html
