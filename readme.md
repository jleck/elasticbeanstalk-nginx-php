# AWS Elastic Beanstalk Nginx/PHP-FPM Build

## Overview

By default PHP on Elastic Beanstalk runs on Apache, which is also a dependancy of Hostmanager. The goal of this project is to provide an easy way to replace Apache with Nginx and PHP-FPM. Simply transfer build.sh onto a fresh Beanstalk AMI instance, and run using sudo.

## Change Log
21/10/2012: Updated PHP 5.4, thanks to Rubas (https://github.com/rubas)

09/11/2012: Corrected bug with history command

## Why?

Elastic Beanstalk is a great service, but as the concurrency increases, apache chews up a lot of resources. Nginx with PHP-FPM is a lethal combination for a dynamic web server, and perfect for large scale websites.

Support for a deployment scripts has also been added. Simply create preDeploy.sh and/or postDeploy.sh scripts in the root of your application, and they will be run on deployment. Note the scripts must delete themselves after running, or deployment will fail. You can do this by adding the following to the end of the scripts:

```bash
rm -f /var/www/html/preDeploy.sh
```

## Installation

1. Launch an existing PHP Beanstalk AMI in EC2 (not through beanstalk!). Tested with 'amazon/PHPBeanstalk64-2012.09.01T01.45.48.0000'.
2. Connect via SSH, and run:

```bash
sudo curl http://raw.github.com/carboncoders/elasticbeanstalk-nginx-php/master/build.sh | bash
```

3. Exit SSH, and create create an image (EBS AMI) of the instance.
4. Set an application to use the new custom AMI ID.

## What does it actually do?

1. Update all packages
2. Remove Apache and related files
3. Install Nginx and delete default config files
4. Stop Nginx from starting automatically
5. Install PHP-FPM and stop from starting automatically
6. Install Composer in /usr/bin for use across server
6. Download a tarball of this repository
7. Unzip and overwrite files in Nginx, PHP-FPM and Hostmanager
8. Remove zip file and change ownership of directories to elasticbeanstalk
9. Update all packages
10. Clear any current logs