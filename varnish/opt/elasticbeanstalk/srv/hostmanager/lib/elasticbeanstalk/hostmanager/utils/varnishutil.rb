#############################################################################
# AWS Elastic Beanstalk Varnish/PHP-FPM Configuration
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
