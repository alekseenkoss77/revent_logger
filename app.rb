#!/usr/bin/env ruby

require './listener.rb'
require './elastic_logger.rb'
require 'securerandom'

rabbit_params = {
  username: 'revent',
  password: 'revent_secret'
}

p "Start listening..."

logger = ElasticLogger.new host: 'http://127.0.0.1:9200'
logger.write({SecureRandom.hex(3) => SecureRandom.hex(10)})
# Listener.start('task_queue', rabbit_params) do |listener, payload|
#   logger.write(payload)
# end

p "End listening...Exit."
