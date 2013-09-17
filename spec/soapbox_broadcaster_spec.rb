require 'timeout'
require 'rspec'
require_relative '../soapbox_broadcaster'
require_relative '../simple_client'

describe SimpleBroadcaster do

  let(:simple_broadcaster) { SimpleBroadcaster.new }
  let(:host) { '127.0.0.1' }
  let(:port) { 32123 }
  let(:running_broadcaster) {
    # thread will die if the timeout dies, thread will die if
    # test is done ?
    simple_broadcaster.bind host, port
    t=Thread.new { 
      Timeout::timeout(5) {
        loop {
          simple_broadcaster.cycle
          sleep 0.1
        }
        Thread.stop
      } rescue 'server timeout'
    }
    t
  }
  # must start these after broadcaster
  let(:writer) { SimpleClient.new host, port }
  let(:writer2) { SimpleClient.new host, port }
  let(:reader) { SimpleClient.new host, port }
end
