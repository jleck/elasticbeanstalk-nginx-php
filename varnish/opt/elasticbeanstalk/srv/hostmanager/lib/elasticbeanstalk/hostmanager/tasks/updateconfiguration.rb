#############################################################################
# AWS Elastic Beanstalk Host Manager
# Copyright 2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the “License”). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
# http://aws.amazon.com/asl/
#
# or in the “license” file accompanying this file. This file is
# distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, express or implied. See the License for the specific
# language governing permissions and li:Q:Qmitations under the License.
#

require 'fileutils'
require 'json'
require 'elasticbeanstalk/hostmanager/security/aes'
require 'elasticbeanstalk/hostmanager/tasks/task'
require 'elasticbeanstalk/hostmanager/utils/nginxutil'
require 'elasticbeanstalk/hostmanager/utils/phputil'
require 'elasticbeanstalk/hostmanager/utils/fpmutil'
require 'elasticbeanstalk/hostmanager/utils/varnishutil'

module ElasticBeanstalk
  module HostManager
    module Tasks

      class UpdateConfiguration < Task
        def run
          # Store config version
          # NOTE - this is a temporary, backwards compatible way of storing
          # the config version
          config_ver =
            Version.from_url(:configuration, @parameters['configUrl'], @parameters)

          config_ver_url = config_ver.to_url

          ## Download Configuration Property file
          get_config_op = proc {
            ElasticBeanstalk::HostManager.state.transition_to(:updating_configuration, :metric => ElasticBeanstalk::HostManager::Metric.create('UpdateConfiguration'))

            begin
              ElasticBeanstalk::HostManager.log "Retrieving config file from #{config_ver_url}"

              ElasticBeanstalk::HostManager.config.sync_config(config_ver)

              ElasticBeanstalk::HostManager.log 'Configuration updated'
              Event.store(class_name, 'Configuration updated', :info, [ :configuration, :update ], false)

              # Restart app server if the change severity is set ot medium
              if (ElasticBeanstalk::HostManager.config.elasticbeanstalk['HostManager'] &&
                  ElasticBeanstalk::HostManager.config.elasticbeanstalk['HostManager']['Change Severity'] &&
                  ElasticBeanstalk::HostManager.config.elasticbeanstalk['HostManager']['Change Severity'].downcase == 'medium')

                ElasticBeanstalk::HostManager::Applications::PHPApplication.ensure_configuration

                ElasticBeanstalk::HostManager.log "Configuration options passed to the container: #{ElasticBeanstalk::HostManager.config}"

                ElasticBeanstalk::HostManager::Utils::FPMUtil.restart
                ElasticBeanstalk::HostManager::Utils::NginxUtil.restart
                ElasticBeanstalk::HostManager::Utils::VarnishUtil.restart
              end
            rescue
              error_msg = "Failed to update config from #{config_ver_url}: #{$!}\n#{$@.join("\n")}"

              logger.warn(error_msg)
              ElasticBeanstalk::HostManager.log error_msg
              Event.store(class_name, error_msg, :warn, [ :configuration, :update ])
            ensure
              ElasticBeanstalk::HostManager.state.transition_to(:ready) { |state|
                unless (state.context[:metric].nil?)
                  state.context[:metric].end_time = DateTime.now
                  state.context[:metric].save
                end
              }
            end
          }

          EM.defer(get_config_op)

          generate_response(:deferred)
        end

      end ## UpdateConfiguration class

    end ## Tasks module
  end ## HostManager module
end ## ElasticBeanstalk module
