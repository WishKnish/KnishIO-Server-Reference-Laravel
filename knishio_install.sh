# Configure local environment settings
KNISHIO_HOST=knishnode.local
KNISHIO_DB_USERNAME=knishio_user
KNISHIO_DB_PASSWORD=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w "${1:-32}" | head -n 1)
KNISHIO_DB=knishio
KNISHIO_SECRET=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w "${1:-2048}" | head -n 1)
KNISHIO_SOKETI_SECRET=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w "${1:-32}" | head -n 1)
KNISHIO_DIST=$(lsb_release -is)

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

#######################################
##    STOP! PLEASE READ CAREFULLY    ##
#######################################

This script will install all necessary libraries to deploy a Knish.IO Laravel Reference Server. It will make changes to your operating system environment and packages.

By continuing, you accept responsibility for any and all consequences of this action.

Please inspect the source code of this script before continuing.

Sincerely,

WishKnish Team
https://knish.io

#######################################
##    STOP! PLEASE READ CAREFULLY    ##
#######################################
EOF

read -p "Are you sure you wish to continue? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

cat << EOF
#######################################
##   INSTALLING REQUIRED PACKAGES    ##
#######################################
EOF

# Install required packages
sudo apt install -y git curl python3 gcc build-essential

if [ "$KNISHIO_DIST" == "Raspbian" ] || [ "$KNISHIO_DIST" == "Debian" ]
then
    # For Raspberry Pi-based distros
    curl https://packages.sury.org/php/apt.gpg | sudo tee /usr/share/keyrings/suryphp-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/suryphp-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
else
    # For Ubuntu-based distros
    sudo add-apt-repository ppa:ondrej/php -y
fi

sudo apt update
sudo apt upgrade -y
sudo apt remove apache2
sudo apt install -y php8.1 php8.1-fpm php8.1-dom php8.1-zip php8.1-redis php8.1-curl php8.1-mbstring php8.1-mysql php8.1-bcmath mariadb-server redis nginx supervisor

cat << EOF
#######################################
##   INSTALLING NODEJS AND SOKETI    ##
#######################################
EOF

# Install NodeJS and Soketi
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
sudo -u www-data touch /var/www/.npmrc
sudo -u www-data npm config set prefix '/var/www/.npm-global'
sudo -u www-data npm install -g @soketi/soketi
sudo touch /etc/supervisor/conf.d/soketi.conf
sudo tee /etc/supervisor/conf.d/soketi.conf <<EOF
[program:soketi]
process_name=%(program_name)s_%(process_num)02d
command=/var/www/.npm-global/bin/soketi start --config=/var/www/html/soketi_config.json
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=1
redirect_stderr=true
stdout_logfile=/var/log/soketi-supervisor.log
stopwaitsecs=60
stopsignal=sigint
minfds=10240
EOF

cat << EOF
#######################################
##        INSTALLING COMPOSER        ##
#######################################
EOF

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

read -p "Required packages have been installed. Continue to Knish.IO repo installation? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

cat << EOF
#######################################
##       CLONING KNISH.IO REPO       ##
#######################################
EOF

# Clone Knish.IO repository
git clone https://github.com/WishKnish/KnishIO-Server-Reference-Laravel.git
cd "KnishIO-Server-Reference-Laravel" || exit
git config --add core.symlinks true

cat << EOF
#######################################
##   INSTALLING COMPOSER PACKAGES    ##
#######################################
EOF

# Download dependencies
composer install

# Some operating systems don't correctly respect symlinks, so we'll manually create it just in case
ln -sf ../SHA3.php ./vendor/desktopd/php-sha3-streamable/src/SHA3.php

cat << EOF
#######################################
##        SETTING UP DATABASE        ##
#######################################
EOF

# Set up database and user
sudo mysql -uroot -p -e"CREATE DATABASE $KNISHIO_DB"
sudo mysql -uroot -p -e"GRANT ALL PRIVILEGES ON $KNISHIO_DB.* TO $KNISHIO_DB_USERNAME@localhost IDENTIFIED BY \"$KNISHIO_DB_PASSWORD\""
sudo mysql -uroot -p -e"FLUSH PRIVILEGES"

cat << EOF
#######################################
##    WRITING ENVIRONMENT CONFIG     ##
#######################################
EOF

# Creating .env file
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

# Generating Laravel keys
php artisan key:generate

# Creating Soketi config file
tee soketi_config.json <<EOF
{
    "debug": true,
    "port": 6002,
    "appManager.array.apps": [
        {
            "id": "knishio",
            "key": "knishio",
            "secret": "$KNISHIO_SOKETI_SECRET",
            "webhooks": [
                {
                    "url": "https://...",
                    "event_types": ["channel_occupied"]
                }
            ]
        }
    ]
}
EOF

# Modify hosts file
echo "127.0.0.1 $KNISHIO_HOST" | sudo tee -a /etc/hosts

cat << EOF
#######################################
##   MIGRATING DATABASE STRUCTURE    ##
#######################################
EOF

# Migrate database
php artisan migrate

cat << EOF
#######################################
##     CONFIGURING NGINX SERVER      ##
#######################################
EOF

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

cat << EOF
#######################################
##      FINALIZING INSTALLATION      ##
#######################################
EOF

# Move web content
cd ..
sudo rm -rf /var/www/html
sudo mv KnishIO-Server-Reference-Laravel /var/www/html
sudo chown -R www-data:www-data /var/www

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl reload
