#############################################################################
# AWS ElasticBeanstalk Host Manager
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
# language governing permissions and limitations under the License.
#

require 'elasticbeanstalk/hostmanager/tasks/task'
require 'elasticbeanstalk/hostmanager/utils/nginxutil'
require 'elasticbeanstalk/hostmanager/utils/fpmutil'

module ElasticBeanstalk
  module HostManager
    module Tasks

      class RestartAppServer < Task
        def run
          Event.store(:nginx, 'Restarting the app server', :info, [ :milestone, :nginx ], false)
          HostManager.log 'Restarting the app server'

          ElasticBeanstalk::HostManager::Utils::FpmUtil.restart
          ElasticBeanstalk::HostManager::Utils::NginxUtil.restart

          generate_response(:deferred)
        end
      end # RestartAppServer class

    end # Tasks module
  end # HostManager module
end # ElasticBeanstalk module
