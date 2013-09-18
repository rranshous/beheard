require_relative 'channel_receiver'
require_relative 'simple_broadcaster'

class SoapboxBroadcaster
  include ChannelReceiver
  def handle_message msg
    puts "handling message: #{msg}"
    send_message msg.merge source_conn_id: msg[:conn_id] if msg[:data]
  end
end
