require 'socket'
class SimpleClient
  def initialize host, port
    @host, @port = host, port
    @socket = TCPSocket.open @host, @port
  end
  def puts data, timeout=2
    Timeout::timeout(timeout) {
      @socket.puts data
    }
  end
  def gets timeout=2
    read = nil
    Timeout::timeout(timeout) {
      read = @socket.gets.strip
    } rescue 'gets timeout'
    return read
  end
  def close
    @socket.close
  end
end
