require 'socketeer'

class IQueue < Queue
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

  def send_message conn_id, message
    @message_handler.out_queue << { conn_id: conn_id,
                                    data: message }
  end

  def register_socket socket
    @server.instance_eval do
      handle_socket_connect socket
    end
  end

end
