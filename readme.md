# AWS Elastic Beanstalk Nginx/PHP-FPM Build
# Includes optional Varnish cache, Composer and deployment hooks

### Overview

By default PHP on Elastic Beanstalk runs on Apache, which is also a dependancy of Hostmanager. The goal of this project is to provide an easy way to replace Apache with Nginx, PHP-FPM, and optionally Varnish. Simply transfer the  build script onto a fresh Beanstalk AMI instance, and run using sudo bash.

### Advantages

Elastic Beanstalk is a great service, but as the concurrency increases, apache chews up a lot of resources. Nginx with PHP-FPM is a lethal combination for a dynamic web server, and perfect for large scale websites. Varnish adds a fast cache in front of Nginx, and can increas the speed of web content delivery by up to 300%!

### Options

Several options are available when running the build script:

--composer       install Composer

-h|--help        show usage guide

--varnish        install Varnish

-v|--version     show build script version

### Example installation

```bash
wget https://raw.github.com/carboncoders/elasticbeanstalk-nginx-php/master/build
sudo bash build --composer --varnish
```