#!/bin/bash

# Remove Apache2.2 and PHP5.3
yum -y remove httpd httpd-tools
yum -y remove php-cli php-common php 

# Install PHP5.4 (with httpd2.4 as dep)
yum -y install php54* --exclude=php54-mysqlnd 

# Install Nginx
yum -y install nginx
rm -rf /etc/nginx/conf.d/*
chkconfig nginx off

# Install PHP-FPM
yum -y install php54-fpm 
chkconfig php-fpm off

# Update all packages
yum -y update

# Overwrite files in /etc and /opt
mkdir /tmp/build
git clone git://github.com/statichippo/elasticbeanstalk-nginx-php.git /tmp/build
cp -rf /tmp/build/etc /
cp -rf /tmp/build/opt /

# Install Composer
cd /tmp/
curl -s http://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Take ownership
chown -R elasticbeanstalk:elasticbeanstalk /etc/nginx/conf.d \
                                           /opt/elasticbeanstalk \
                                           /usr/bin/composer \
                                           /var/log/nginx \
                                           /var/log/php-fpm


# Clear unneeded files
rm -rf /etc/httpd \
       /opt/elasticbeanstalk/var/log/* \
       /tmp/build \
       /var/log/httpd \
       /var/log/nginx/* \
       /var/log/php-fpm/*

# Clear root history
history -c