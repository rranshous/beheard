require 'socketeer'

class IQueue < Queue
end

# We take a msg and from it create a msg to each
# other connection in the channel, not including the sender
class ChannelRecipientFan
  
  include Messenger

  attr_reader :channel_lookup

  def initialize channel_lookup
    @channel_lookup = channel_lookup
  end

  def cycle
    in_msg = pop_message
    return if in_msg.nil?
    puts "fan in_msg: #{in_msg}"
    channel_id = in_msg[:channel_id]
    puts "fan channel_id: #{channel_id}"
    channel_lookup
    .select { |_, cid| cid == channel_id }
    .select { |cid, _| cid != in_msg[:source_conn_id] }
    .each do |conn_id, _|
      puts "fanning #{conn_id}"
      push_message in_msg.merge conn_id: conn_id
    end
  end
end

# We buffer the data until we get a channel id deliminater
# we than let messages from those conns through, adding the
# channel name to the msg
class ChannelDecider

  include Messenger

  attr_reader :channel_lookup

  def initialize channel_lookup
    @channel_lookup = channel_lookup
  end
  
  def cycle
    in_msg = pop_message
    return if in_msg.nil?
    puts "decider msg: #{in_msg}"
    conn_id = in_msg[:conn_id]
    data = in_msg[:data]
    if channel_lookup.include? conn_id
      puts "decider from lookup: #{channel_lookup[conn_id]}"
      push_message in_msg.merge channel_id: channel_lookup[conn_id]
    else
      puts "decider to buffer"
      data_buffer[conn_id] ||= ''
      data_buffer[conn_id] += data
      if data_buffer[conn_id].include? "\n"
        puts "found delim"
        channel_id, remaining_data = data_buffer[conn_id].split("\n")
        channel_lookup[conn_id] = channel_id
        data_buffer.delete conn_id
        puts "remaining data: #{remaining_data}"
        if remaining_data.nil? || remaining_data.empty?
          push_message in_msg.merge data: remaining_data, channel_id: channel_id
        end
      end
    end
  end

  # conn_id => data string
  def data_buffer
    @data_buffer ||= {}
  end

end

module ChannelReceiver

  def bind host, port, &callback
    # will use the passed callback if provided, else calls handle_message
    callback ||= proc { |m| handle_message m }
    @server = Server.new host, port, Handler
    @message_handler = MessageHandler.new &callback 
    @channel_lookup = {}
    @channel_decider = ChannelDecider.new @channel_lookup
    @channel_recipient_fan = ChannelRecipientFan.new @channel_lookup

    @server.bind_queues IQueue.new, IQueue.new
    @message_handler.bind_queues IQueue.new, IQueue.new
    @channel_decider.bind_queues IQueue.new, IQueue.new
    @channel_recipient_fan.bind_queues IQueue.new, IQueue.new

    @pipeline = Pipeline.new(@server,
                             @channel_decider,
                             @message_handler, 
                             @channel_recipient_fan,
                             @server)
    [host, port]
  end

  def cycle
    @pipeline.cycle
  end

  private

  def handle_message message
  end

  def send_message data
    @message_handler.out_queue << data
  end

  def register_socket socket
    @server.instance_eval do
      handle_socket_connect socket
    end
  end

end
