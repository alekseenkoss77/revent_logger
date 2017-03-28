#!/usr/bin/env ruby

puts "Run process parent"

pid = fork do
  i = 0
  file = File.new("1.txt", "w")
  loop do
    file.write("Child process iteration - #{i}")
    i += 1
    sleep 3
  end
  file.close()
end

exit
