require 'socketeer'

class IQueue < Queue
end

# over ride the server so that we can over ride outbound message
# handling not to echo messages
class Server
  def handle_new_message message
    return if message.nil?
    unless message[:conn_id].nil?
      @connections[message[:conn_id]].in_queue << message[:data]
    else
      @connections.each do |conn_id, conn|
        next if message[:source_conn_id] == conn_id
        conn.in_queue << message[:data]
      end
    end
  end
end

module SimpleReceiver

  def bind host, port, &callback
    # will use the passed callback if provided, else calls handle_message
    callback ||= proc { |m| handle_message m }
    @server = Server.new host, port, Handler
    @message_handler = MessageHandler.new &callback 
    @server.bind_queues IQueue.new, IQueue.new
    @message_handler.bind_queues IQueue.new, IQueue.new

    @pipeline = Pipeline.new(@server,
                             @message_handler, 
                             @server)
    [host, port]
  end

  def cycle
    @pipeline.cycle
  end

  private

  def handle_message message
  end

  def send_message conn_id, message, opts={}
    @message_handler.out_queue << { conn_id: conn_id,
                                    data: message }.merge(opts)
  end

  def register_socket socket
    @server.instance_eval do
      handle_socket_connect socket
    end
  end

end
