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
