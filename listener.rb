#!/usr/bin/env ruby

require 'bunny'

class Listener
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 5672
  DEFAULT_PASSWORD = 'guest'
  DEFAULT_USERNAME = 'guest'
  RETRY_COUNT = 2

  attr_reader :connection, :channel, :queue

  def initialize(opts = {})
    @rabbit_options = opts
    @rabbit_options[:host] ||= DEFAULT_HOST
    @rabbit_options[:port] ||= DEFAULT_PORT
    @rabbit_options[:username] ||= DEFAULT_USERNAME
    @rabbit_options[:password] ||= DEFAULT_PASSWORD
  end

  def self.start(queue_name, options = {}, &block)
    new(options).start(queue_name, &block)
  end

  def start(queue_name, &block)
    @connection = Bunny.new(@rabbit_options)
    connection.start

    @channel = connection.create_channel
    @queue = listen_queue(queue_name)

    begin
      queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
        retry_count = RETRY_COUNT
        begin
          yield(self, body)
        rescue => e
          if retry_count <= 0
            next
          end
          retry_count -= 1
          
          retry
        ensure
          ack(delivery_info.delivery_tag)
        end
      end
    rescue Interrupt => e
      connection.close
      exit
    end
  end

  def listen_queue(name)
    que = channel.queue(name, durable: true)
    channel.prefetch(1)
    que
  end

  def ack(tag)
    channel.ack(tag)
  end
end
