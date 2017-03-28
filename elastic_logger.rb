#!/usr/bin/env ruby

require 'elasticsearch'
require 'elasticsearch-transport'
require 'json'
require 'pry-byebug'

class ElasticLogger
  DEFAULT_HOST = '127.0.0.1'
  RELOAD_CONNECTION_AFTER = 10
  RETRY_ON_FAILURE = 2
  DEFAULT_TIMEOUT = 20
  DB_INDEX_NAME = 'tb_revent_logs'

  attr_reader :message, :client, :options
  
  def initialize(opts = {})
    @options = opts
    @options[:host] ||= DEFAULT_HOST
    @options[:reload_connections] ||= RELOAD_CONNECTION_AFTER
    @options[:retry_on_failure] ||= RETRY_ON_FAILURE
    @options[:reload_on_failure] ||= true
    @options[:request_timeout] ||= DEFAULT_TIMEOUT
    @options[:log] = true

    @client ||= Elasticsearch::Client.new options
  end

  def write(data)
    @message = data

    begin
      msg = deserialized_message
      return unless msg.present?

      push_data(msg)
    rescue => e
      reconnect!
      push_data(msg)
    end
  end

  private

  def push_data(msg)
    client.index(
      index: DB_INDEX_NAME,
      type: 'json',
      body: msg
    )
  end

  def reconnect!
    client.transport.reload_connections!
  end

  def deserialized_message
    return message if message.is_a?(Hash) || message.is_a?(Array)

    begin
      JSON.parse(message)
    rescue => e
      nil
    end
  end
end
