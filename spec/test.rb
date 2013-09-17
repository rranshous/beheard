require_relative '../app'

sb = SimpleBroadcaster.new
sb.bind 'localhost', 32123
loop do
  sb.cycle
  puts 'cycling'
  sleep 1
end
