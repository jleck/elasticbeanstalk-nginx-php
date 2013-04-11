#
# AWS Elastic Beanstalk Nginx/PHP-FPM Configuration
#
# @author    James Leckenby <me@jleck.co.uk>
# @link      http://jleck.co.uk
# @copyright 2013 James Leckenby
# @license   MIT License
# @version   1.0
#

module ElasticBeanstalk
  module HostManager
    module Utils

      class VarnishUtil
        
        def self.log(msg, *args)
          HostManager.log msg
          Event.store(:varnish, msg, *args)
        end

        def self.execute_varnish_cmd(verb, status_regex = /FAILED/)
          log("Executing Varnish Command: #{verb}", :info, [ :milestone, :varnish ], false)

          output = `/usr/bin/sudo /etc/init.d/varnish #{verb}`

          if ($?.exitstatus != 0 || output =~ status_regex)
            log("Varnish #{verb} FAILED", :critical, [ :varnish ])
          else
            log("Varnish #{verb} succeeded", :info, [ :milestone, :varnish ], false)
          end
        end

        def self.start
          execute_varnish_cmd('start')
          `/usr/bin/sudo /usr/bin/varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban.url .`
        end

        def self.stop
          execute_varnish_cmd('stop')
        end

        def self.restart
          execute_varnish_cmd('restart', /Starting Varnish\: \[FAILED\]/)
          `/usr/bin/sudo /usr/bin/varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban.url .`
        end

        def self.status
          `/usr/bin/sudo /etc/init.d/varnish status`.chomp
        end
      end
    end
  end
end
