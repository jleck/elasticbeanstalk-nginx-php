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
