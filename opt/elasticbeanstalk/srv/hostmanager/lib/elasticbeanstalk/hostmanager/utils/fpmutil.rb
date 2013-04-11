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

      class FpmUtil
        
        def self.log(msg, *args)
          HostManager.log msg
          Event.store(:fpm, msg, *args)
        end

        def self.execute_fpm_cmd(verb, status_regex = /FAILED/)
          log("Executing FPM Command: #{verb}", :info, [ :milestone, :fpm ], false)

          output = `/usr/bin/sudo /etc/init.d/php-fpm #{verb}`

          if ($?.exitstatus != 0 || output =~ status_regex)
            log("FPM #{verb} FAILED", :critical, [ :fpm ])
          else
            log("FPM #{verb} succeeded", :info, [ :milestone, :fpm ], false)
          end
        end

        def self.start
          execute_fpm_cmd('start')
        end

        def self.stop
          execute_fpm_cmd('stop')
        end

        def self.restart
          execute_fpm_cmd('restart', /Starting FPM\: \[FAILED\]/)
        end

        def self.status
          `/usr/bin/sudo /etc/init.d/php-fpm status`.chomp
        end
      end
    end
  end
end
