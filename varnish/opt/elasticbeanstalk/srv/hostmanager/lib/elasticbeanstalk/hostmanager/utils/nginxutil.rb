#############################################################################
# AWS Elastic Beanstalk Nginx/PHP-FPM Configuration
# Copyright 2012 Carbon Coders Ltd.
#
# MIT LICENSE
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

module ElasticBeanstalk
  module HostManager
    module Utils

      class NginxUtil
        
        def self.log(msg, *args)
          HostManager.log msg
          Event.store(:nginx, msg, *args)
        end

        def self.execute_nginx_cmd(verb, status_regex = /FAILED/)
          log("Executing Nginx Command: #{verb}", :info, [ :milestone, :nginx ], false)

          output = `/usr/bin/sudo /etc/init.d/nginx #{verb}`

          if ($?.exitstatus != 0 || output =~ status_regex)
            log("Nginx #{verb} FAILED", :critical, [ :nginx ])
          else
            log("Nginx #{verb} succeeded", :info, [ :milestone, :nginx ], false)
          end
        end

        def self.start
          execute_nginx_cmd('start')
        end

        def self.stop
          execute_nginx_cmd('stop')
        end

        def self.restart
          execute_nginx_cmd('restart', /Starting Nginx\: \[FAILED\]/)
        end

        def self.status
          `/usr/bin/sudo /etc/init.d/nginx status`.chomp
        end

        def self.update_nginx_conf(nginx_options = nil)
          return if nginx_options.nil?

          log('Updating Nginx configuration', :info, [ :milestone, :nginx ], false)

          # Make sure the document root is set and sanitized
          nginx_options['document_root'] = '' if nginx_options['document_root'].nil?
          nginx_options['document_root'] = '/' + nginx_options['document_root']
          nginx_options['document_root'].tap do |docroot|
            docroot.strip!
            docroot.squeeze!('/')
            docroot.chomp!('/')
            docroot.gsub!(/(?:\.\.\/|\.\/|[^\w\.\-\~\/])/, '_')
          end

          log('Writing Nginx application configuration', :info, [ :milestone, :nginx ], false)
          vhosts_file = ::File.open('/etc/nginx/conf.d/server.conf', 'w') do |file|
          file.puts <<-CONFIG
#############################################################################
# AWS Elastic Beanstalk Nginx/PHP-FPM Configuration
# Copyright 2012 Carbon Coders Ltd.
#
# MIT LICENSE
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Example server created on deploy by Hostmanager
server {
    listen 8080;
    root /var/www/html#{nginx_options['document_root']}; # Changed on deploy
    index index.php index.html;
    log_not_found off;
    access_log off;

    # Try file, folder and then root index
    location / {
        try_files $uri $uri/ /index.php;
    }

    # Proxy requests to Hostmanager server
    location /_hostmanager/ {
        proxy_pass http://127.0.0.1:8999/;
    }

    # Process PHP requests with PHP-FPM
    location ~* .php$ {
        try_files $uri $uri/ /index.php =404; # Exploit defence
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock; # Using socket, faster

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SCRIPT_NAME     $fastcgi_script_name;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    # Cache static files
    location ~* .(jpg|jpeg|gif|png|css|js|ico|xml)$ {
        expires 360d;
    }

    # Block access to protected extensions and hidden files
    location ~* .(log|md|sql|txt)$ { deny all; }
    location ~ /\\.                 { deny all; }
}
CONFIG
          end

          log('Nginx configuration file failed to be written', :critical, [ :nginx ]) unless ::File.exists?('/etc/nginx/conf.d/server.conf')

          ElasticBeanstalk::HostManager.log(nginx_options)
        end
      end
    end
  end
end
