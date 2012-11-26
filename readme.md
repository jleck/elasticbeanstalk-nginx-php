# AWS Elastic Beanstalk Nginx/PHP-FPM Build
### Includes optional Varnish cache, Composer and deployment hooks

## Overview

By default PHP on Elastic Beanstalk runs on Apache, which is also a dependancy of Hostmanager. The goal of this project is to provide an easy way to replace Apache with Nginx, PHP-FPM, and optionally Varnish. Simply transfer the build script onto a fresh Beanstalk AMI instance, and run using sudo bash.

## Advantages

Elastic Beanstalk is a great service, but as the concurrency increases, apache chews up a lot of resources. Nginx with PHP-FPM is a lethal combination for a dynamic web server, and perfect for large scale websites. Varnish adds a fast cache in front of Nginx, and can increas the speed of web content delivery by up to 300%!

## Options

Several options are available when running the build script:

`--composer` install Composer

`-h|--help` show usage guide

`--varnish` install Varnish

`--ssl` enable SSL

`-v|--version` show build script version

Deployment hooks are also available for use, simply create preDeploy.sh and/or postDeploy.sh scripts in the root of your application, and they will be run on deployment. Note the scripts must delete themselves after running, or deployment will fail. You can do this by adding the following to the end of the scripts:

```bash
rm -f ${0##*/}
```

#### More on SSL
The `--ssl` option creates a copy of the default nginx config with ssl enabled. Encryption is done via a self-signed SSL certificate valid for 1 year from the build script run date. The purpose of this self-signed SSL cert is to encrypt traffic between the Elastic Load Balancer and your instance; *you will still want to install a trusted SSL certificate on your Elastic Load Balancer*. HTTPS traffic will then be encrypted between the browser and Elastic Load Balancer using your trusted certificate, decrypted on the Elastic Load Balancer and re-encrypted between the Elastic Load Balancer using the self signed cert.

## Example installation

1. Create a new EC2 instance using a Beanstalk AMI (tested on ami-95c6c0e1, PHPBeanstalk64-2012.09.01T01.59.38.000).
2. SSH into the instance and run:

```bash
wget https://raw.github.com/carboncoders/elasticbeanstalk-nginx-php/master/build

sudo bash build --composer --varnish
```

3. Exit SSH, and create new image from instance.
4. Set custom Custom AMI ID to newly saved image and relax :)