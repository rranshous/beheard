require_relative 'channel_receiver'
require_relative 'simple_broadcaster'

class SoapboxBroadcaster
  include ChannelReceiver
end
