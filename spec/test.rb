require_relative '../soapbox_broadcaster'

sb = SoapboxBroadcaster.new
sb.bind 'localhost', 32123
loop do
  sb.cycle
  sleep 0.1
end
