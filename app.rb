require_relative 'simple_receiver'

# we are going to broadcast everything we receive to everyone
class SimpleBroadcaster
  include SimpleReceiver

  def handle_message msg
    # grab our data off the line
    data = msg[:data]
    # send it to everyone (no receiver conn_id = everyone)
    send_message nil, data
  end

end
