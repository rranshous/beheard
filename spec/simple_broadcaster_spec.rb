require 'timeout'
require 'rspec'
require_relative '../simple_broadcaster'
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

  before :each do
    puts 'before'
    # start everyone up
    running_broadcaster
    # give the server a second to bind
    sleep 1
    writer
    writer2
    reader
    # another second to conn
    sleep 1
    puts 'done before'
  end

  after :each do
    # stop everyone
    puts 'after stopping'
    simple_broadcaster.instance_eval do
      @server.instance_eval do
        @tcp_server.close
      end
    end
    running_broadcaster.exit
    writer.close
    writer2.close
    reader.close
    puts 'done after stopping'
  end

  it "broadcasts what one client sends back out to all clients" do
    writer.puts "test_one"
    reader.gets.should == "test_one"
  end

  it "should not echo back to the sender" do
    writer.puts "test"
    writer.gets.should == nil
  end
end
