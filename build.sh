#!/bin/bash
cd /

# Update all packages
yum -y update

# Remove Apache
yum -y remove httpd

# Install Nginx
yum -y install nginx
rm -rf /etc/nginx/conf.d/*
chkconfig nginx off

# Install PHP-FPM
yum -y install php-fpm
chkconfig php-fpm off

# Overwrite files in /etc and /opt
mkdir /tmp/build
wget -O /tmp/build/build.tar.gz https://github.com/carboncoders/elasticbeanstalk-nginx-php/tarball/master
tar -C /tmp/build -zxvf /tmp/build/build.tar.gz
DIR=`find /tmp/build/carboncoders-elasticbeanstalk* -prune -type d`
cp -rf $DIR/etc /
cp -rf $DIR/opt /

# Install Composer
curl -s http://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Take ownership
chown -R elasticbeanstalk:elasticbeanstalk /etc/nginx/conf.d \
                                           /opt/elasticbeanstalk \
                                           /usr/bin/composer \
                                           /var/log/nginx \
                                           /var/log/php-fpm

# Check for more updates
yum -y update

# Clear unneeded files
rm -rf /etc/httpd \
       /opt/elasticbeanstalk/var/log/* \
       /tmp/build \
       /var/log/httpd \
       /var/log/nginx/* \
       /var/log/php-fpm/*

# Clear root history
history -c