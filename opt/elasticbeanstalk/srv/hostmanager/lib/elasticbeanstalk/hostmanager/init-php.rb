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
# language governing permissions and limitations under the License.
#

require 'elasticbeanstalk/hostmanager/applications'
require 'elasticbeanstalk/hostmanager/daemonmanager'
require 'elasticbeanstalk/hostmanager/daemon/logdirectorymonitor'
require 'elasticbeanstalk/hostmanager/deploymentmanager'
require 'elasticbeanstalk/hostmanager/models/event'
require 'elasticbeanstalk/hostmanager/models/filepublication'
require 'elasticbeanstalk/hostmanager/models/metric'
require 'elasticbeanstalk/hostmanager/models/version'
require 'elasticbeanstalk/hostmanager/utils/nginxutil'
require 'elasticbeanstalk/hostmanager/utils/bluepillutil'
require 'elasticbeanstalk/hostmanager/utils/ec2util'
require 'elasticbeanstalk/hostmanager/utils/phputil'
require 'elasticbeanstalk/hostmanager/utils/fpmutil'

ElasticBeanstalk::HostManager::DaemonManager.instance.add(ElasticBeanstalk::HostManager::LogDirectoryMonitor.new('/var/log/nginx', 'gz\Z'))
ElasticBeanstalk::HostManager.config.container_type = :php
ElasticBeanstalk::HostManager.config.api_versions << '2011-08-29'

ElasticBeanstalk::HostManager::Server.register_post_init_block {

  ElasticBeanstalk::HostManager::Applications::PHPApplication.ensure_configuration

  application = ElasticBeanstalk::HostManager::Applications::PHPApplication.new(ElasticBeanstalk::HostManager.config.application_version)
  if ElasticBeanstalk::HostManager::DeploymentManager.should_deploy(application)
    application.mark_in_initialization
    ElasticBeanstalk::HostManager.log("Starting initial version deployment.")
    ElasticBeanstalk::HostManager::DeploymentManager.deploy(application)
  else
    ElasticBeanstalk::HostManager.log("Version already deployed. Starting Nginx and FPM.")
    ElasticBeanstalk::HostManager::Utils::BluepillUtil.start_target("fpm")
    ElasticBeanstalk::HostManager::Utils::BluepillUtil.start_target("nginx")
  end
}
