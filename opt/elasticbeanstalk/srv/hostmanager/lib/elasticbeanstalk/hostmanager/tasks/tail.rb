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

require 'elasticbeanstalk/hostmanager/tasks/task'
require 'base64'

module ElasticBeanstalk
  module HostManager
    module Tasks

      class Tail < Task
        class << self
          attr_reader :error_log, :tail_size
        end

        @error_log = '/var/log/nginx/php-error.log'
        @tail_size = 100

        def run
          contents = `/usr/bin/tail -n #{Tail.tail_size} #{Tail.error_log}`
          generate_response(Base64.encode64(contents))
        end
      end

    end # Tasks module
  end
end