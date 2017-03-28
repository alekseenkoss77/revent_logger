#!/usr/bin/env ruby

require "bunny"
threads = []

def thread_id(i)
  "<Thread:##{i}>"
end

1..4.times do |i|
  threads << Thread.fork do |thread|
    id = Thread.current['thread_id'] = thread_id(i)
    
    puts "Tread started: #{id}"
    
    conn = Bunny.new(username: 'revent', password: 'revent_secret')
    conn.start

    ch   = conn.create_channel
    q    = ch.queue("task_queue", :durable => true)

    ch.prefetch(1)

    begin
      q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
        puts " [+] Thread #{id} received '#{body}'"
        ch.ack(delivery_info.delivery_tag)
      end
    rescue Interrupt => _
      conn.close
    end
  end
end

threads.each { |t| t.join }  
