# AWS Elastic Beanstalk Nginx/PHP-FPM Build
### With support for deployment hooks, Varnish and more through addon packages

## Overview

By default PHP on Elastic Beanstalk runs on Apache, which is also a dependancy of Hostmanager. The goal of this project is to provide an easy way to replace Apache with Nginx/PHP-FPM. Addon packages are also supported, enabling support for Varnish, SSL, rsyslog forwarding and more. To use, transfer the build script onto a fresh Beanstalk AMI instance, and execute using bash.

## Advantages

Elastic Beanstalk is a great service, but as the concurrency increases, apache chews up a lot of resources. Nginx with PHP-FPM is a lethal combination for a dynamic web server, and perfect for large scale websites. Optional Varnish support adds a fast cache, and can increase content delivery speed up to 300%!

Deployment hooks are also available. Just add preDeploy.sh/postDeploy.sh to the root of your app, and they will be ran on deployment. An example would be:

```bash
#!/bin/bash
#
# AWS Elastic Beanstalk Nginx/PHP-FPM Configuration
# Copyright 2012 Carbon Coders Ltd

# Navigate to containg folder
FOLDER=`dirname ${0##*/}`
cd $FOLDER

# Run commands
composer install

# Delete self or deploy will fail
rm -f ${0##*/}
```

## Options

Several options are available when running the build script:

`-a|--addons` comma seperated list of addons to install

`-v|--help` show help text

`-v|--version` show script version

## Supported Addons

Addons can be installed using the `--addons` oprion. Accepts GIT clone urls as well as official addons, for example:

````bash
sudo ./build --addons composer,git://github.com/user/repo.git
````

Note that cloned repo must contain a `build` file with install commands, or the script will error. Files must also return 0 or the script will error. Official addons include:

#### composer
Composer is a popular dependency manager for PHP. Make you you run `composer install` in postDeploy.sh to download all required packages. More information can be found [here](http://getcomposer.org).

#### logentries
Rsyslog forwarding is impelemented for [logentries](http://www.logentries.com). You'll need to create a [*token based input*](https://logentries.com/doc/input-token/) and then configure the `logentries.token` Elastic Beanstalk environment property with that token.

#### memcache
Memcached is an in-memory key-value store for small chunks of arbitrary data. More information can be found [here](http://memcached.org).

#### ssl
The ssl option creates a copy of the default Nginx config with ssl enabled. Encryption is done via a self-signed SSL certificate (valid for 1 year from the build script run date). The purpose of this self-signed SSL cert is to encrypt traffic between the Elastic Load Balancer (ELB) and your instance; *you will still want to install a trusted SSL certificate on your Elastic Load Balancer*. HTTPS traffic will be encrypted between the browser and ELB using your trusted certificate, and re-encrypted between the ELB and AWS instance using the self-signed certificate.

#### varnish
Varnish is a web application accelerator, which can increase content delivery speed up to 300%. When installed, it sits infront of Nginx on port 80, while Nginx is moved to run on 8080. More information can be found [here](https://www.varnish-cache.org).

## Example installation

1. Create a new EC2 instance using a Beanstalk AMI, Tested on ami-95c6c0e1 (PHPBeanstalk64-2012.09.01T01.59.38.000), but should work with any PHP Beanstalk AMI.
2. SSH into the instance and run the script, optionally specifying any adons to install:

```bash
wget https://raw.github.com/carboncoders/elasticbeanstalk-nginx-php/master/build
chmod +x build
sudo ./build --addons composer,memcache,varnish
```

3. Exit SSH, and create AMI image from theinstance.
4. Set your application's custom AMI ID to the new image, and enjoy the power of Nginx! :)