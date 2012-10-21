#!/bin/bash

# Remove Apache2.2 and PHP5.3
sudo yum -y remove httpd httpd-tools
sudo yum -y remove php-cli php-common php 

# Install PHP5.4 (with httpd2.4 as dep)
sudo yum -y install php54* --exclude=php54-mysqlnd 

# Install Nginx
sudo yum -y install nginx
sudo rm -rf /etc/nginx/conf.d/*
sudo chkconfig nginx off

# Install PHP-FPM
sudo yum -y install php54-fpm 
sudo chkconfig php-fpm off

# Update all packages
sudo yum -y update

# Overwrite files in /etc and /opt
sudo mkdir /tmp/build
sudo git clone git://github.com/rubas/elasticbeanstalk-nginx-php.git /tmp/build
sudo cp -rf /tmp/build/etc /
sudo cp -rf /tmp/build/opt /

# Install Composer
cd /tmp/
sudo curl -s http://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

# Take ownership
sudo chown -R elasticbeanstalk:elasticbeanstalk /etc/nginx/conf.d \
                                           /opt/elasticbeanstalk \
                                           /usr/bin/composer \
                                           /var/log/nginx \
                                           /var/log/php-fpm


# Clear unneeded files
sudo rm -rf /etc/httpd \
       /opt/elasticbeanstalk/var/log/* \
       /tmp/build \
       /var/log/httpd \
       /var/log/nginx/* \
       /var/log/php-fpm/*

# Clear root history
sudo history -c