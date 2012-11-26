#############################################################################
# AWS Elastic Beanstalk Logentries/PHP-FPM Configuration
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

      class LogentriesUtil
        
        def self.log(msg, *args)
          HostManager.log msg
          Event.store(:logentries, msg, *args)
        end

        def self.update_logentries_conf(logentries_options = nil)
          return if logentries_options.nil? or logentries_options['logentries.token'].nil?

          log('Writing Logentries application configuration', :info, [ :milestone, :logentries ], false)
          vhosts_file = ::File.open('/etc/rsyslog.d/logentries.conf', 'w') do |file|
          file.puts <<-CONFIG
# ### begin forwarding rule ###
# The statement between the begin ... end define a SINGLE forwarding
# rule. They belong together, do NOT split them. If you create multiple
# forwarding rules, duplicate the whole block!
# Remote Logging (we use TCP for reliable delivery)
#
# An on-disk queue is created for this action. If the remote host is
# down, messages are spooled to disk and sent when it is up again.
#$WorkDirectory /var/lib/rsyslog # where to place spool files
#$ActionQueueFileName fwdRule1 # unique name prefix for spool files
#$ActionQueueMaxDiskSpace 1g   # 1gb space limit (use as much as possible)
#$ActionQueueSaveOnShutdown on # save messages to disk on shutdown
#$ActionQueueType LinkedList   # run asynchronously
#$ActionResumeRetryCount -1    # infinite retries if host is down
# remote host is: name/ip:port, e.g. 192.168.0.1:514, port optional
#*.* @@remote-host:514
# ### end of the forwarding rule ###
$DefaultNetstreamDriverCAFile /etc/ssl/certs/logentries.all.crt
$ActionSendStreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode x509/name
$ActionSendStreamDriverPermittedPeer *.logentries.com

$template LogentriesFormat,"#{logentries_options['logentries.token']} %HOSTNAME% %syslogtag%%msg%"
*.* @@api.logentries.com:20000;LogentriesFormat
CONFIG
          end

          log('Logentries configuration file failed to be written', :critical, [ :logentries ]) unless ::File.exists?('/etc/rsyslog.d/logentries.conf')

          # restart rsyslog
          `/usr/bin/sudo /etc/init.d/rsyslog restart`

          ElasticBeanstalk::HostManager.log(logentries_options)
        end
      end
    end
  end
end