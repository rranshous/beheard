require_relative '../app'

sb = SimpleBroadcaster.new
sb.bind 'localhost', 32123
loop do
  sb.cycle
  sleep 0.1
end
