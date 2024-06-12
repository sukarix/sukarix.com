#!/usr/bin/env bash

source /app/vagrant/provision/common.sh

#== Import script args ==

timezone=$(echo "$1")

#== Provision script ==

info "Provision-script user: $(whoami)"

export DEBIAN_FRONTEND=noninteractive

info "Configure timezone"
timedatectl set-timezone ${timezone} --no-ask-password

info "adding ondrej/php repository"
sudo add-apt-repository -y ppa:ondrej/php

info "adding bashtop-monitor/bashtop repository"
sudo add-apt-repository -y ppa:bashtop-monitor/bashtop
sudo apt install -y bashtop

info "Enable Percona PostgreSQL distribution"
sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
sudo rm percona-release_latest.$(lsb_release -sc)_all.deb

info "Update OS software"
sudo apt update
sudo apt upgrade -y

info "Install ubuntu tools"
sudo apt install -y wget gnupg2 lsb-release curl zip unzip nginx-full bc ntp xmlstarlet bash-completion net-tools jq

info "Install Redis for caching"
sudo add-apt-repository -y ppa:redislabs/redis
sudo apt install -y redis-server
sudo systemctl enable redis-server

info "Install borgbackup"
sudo add-apt-repository -y ppa:costamagnagianfranco/borgbackup
sudo apt install -y borgbackup

info "Install PHP 8.3 with its dependencies"
sudo apt install -y php8.3-curl php8.3-cli php8.3-intl php8.3-redis php8.3-gd php8.3-fpm php8.3-pgsql \
  php8.3-mbstring php8.3-xml php8.3-bcmath php8.3-zip php8.3-xdebug

info "Install composer"
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

info "Installing PostgreSQL"
sudo percona-release setup ppg-16.2
sudo apt install -y percona-postgresql-16 \
  percona-postgresql-16-repack \
  percona-postgresql-16-pgaudit \
  percona-pg-stat-monitor16 \
  percona-pgbackrest \
  percona-patroni \
  percona-pgaudit16-set-user \
  percona-pgbadger \
  percona-postgresql-16-wal2json \
  percona-pg-stat-monitor16 \
  percona-postgresql-contrib

info "Configure PHP-FPM"
sudo rm /etc/php/8.3/fpm/pool.d/www.conf
sudo ln -s /app/vagrant/dev/php-fpm/www.conf /etc/php/8.3/fpm/pool.d/www.conf
sudo rm /etc/php/8.3/mods-available/xdebug.ini
sudo ln -s /app/vagrant/dev/php-fpm/xdebug.ini /etc/php/8.3/mods-available/xdebug.ini
echo "Done!"

info "Configure NGINX"
sudo sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"

info "Enabling site configuration"
sudo ln -s /app/vagrant/dev/nginx/app.conf /etc/nginx/sites-enabled/app.conf
echo "Done!"

info "set the default to listen to all addresses"
sudo sed -i "/port*/a listen_addresses = '*'" /etc/postgresql/16/main/postgresql.conf

info "allow any authentication mechanism from any client"
sudo sed -i "$ a host all all all trust" /etc/postgresql/16/main/pg_hba.conf

info "Initializing dev databases and users for PostgreSQL"
sudo -u postgres psql -c "CREATE USER sukarix WITH PASSWORD 'sukarix'"
sudo -u postgres psql -c "CREATE DATABASE sukarix WITH OWNER 'sukarix'"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sukarix TO sukarix;"
echo "Done!"

info "Initializing test databases and users for PostgreSQL"
sudo -u postgres psql -c "CREATE USER sukarix_test WITH PASSWORD 'sukarix_test'"
sudo -u postgres psql -c "CREATE DATABASE sukarix_test WITH OWNER 'sukarix_test'"
sudo -u postgres psql -c "ALTER ROLE sukarix_test SUPERUSER;"
echo "Done!"

info "Installing cron"
sudo ln -s /app/vagrant/dev/cron/vagrant /var/spool/cron/crontabs/vagrant
sudo chown vagrant:crontab /var/spool/cron/crontabs/vagrant
sudo chmod 600 /var/spool/cron/crontabs/vagrant
sudo service cron reload
echo "Done!"
