require_relative 'simple_receiver'

# we are going to broadcast everything we receive to everyone
class SimpleBroadcaster
  include SimpleReceiver

  def handle_message msg
    puts "handling message: #{msg}"
    # grab our data off the line
    data = msg[:data]
    # send it to everyone (no receiver conn_id = everyone)
    send_message nil, data, source_conn_id: msg[:conn_id]
  end

end
