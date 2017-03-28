#!/usr/bin/env ruby

require "bunny"
require "securerandom"

conn = Bunny.new(username: 'revent', password: 'revent_secret')
conn.start

ch   = conn.create_channel
q    = ch.queue("task_queue", :durable => true)

sended_count = 0

loop do
  msg = { "message_#{SecureRandom.hex(3)}" => "body_#{SecureRandom.hex(10)}" }
  q.publish(msg, :persistent => true)
  puts " [x] Sent #{msg}"
  sended_count += 1
  puts "[x] Sended = #{sended_count}"
end

# 1..10.times do |i|
#   msg  = "Message: #{SecureRandom.hex(10)}"
#   q.publish(i.to_s, :persistent => true)
#   puts " [x] Sent #{i}"
#   sended_count += 1
#   puts "[x] Sended = #{sended_count}"
# end


conn.close
