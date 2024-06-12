#!/usr/bin/env bash

source /app/vagrant/provision/common.sh

#== Provision script ==

info "Provision-script user: $(whoami)"

info "Restart web-stack"
service php8.3-fpm restart
service nginx restart
service postgresql restart
hostnamectl set-hostname sukarix.test
