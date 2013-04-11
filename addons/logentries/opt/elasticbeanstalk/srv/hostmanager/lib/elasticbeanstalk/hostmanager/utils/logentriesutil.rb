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

          # Restart rsyslog
          `/usr/bin/sudo /etc/init.d/rsyslog restart`
          ElasticBeanstalk::HostManager.log(logentries_options)
        end
      end
    end
  end
end