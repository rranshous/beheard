require 'timeout'
require 'rspec'
require_relative '../soapbox_broadcaster'
require_relative '../simple_client'

describe SoapboxBroadcaster do

  let(:broadcaster) { SoapboxBroadcaster.new }
  let(:host) { '127.0.0.1' }
  let(:port) { 32123 }
  let(:running_broadcaster) {
    # thread will die if the timeout dies, thread will die if
    # test is done ?
    broadcaster.bind host, port
    t=Thread.new { 
      begin
        Timeout::timeout(5) {
          loop { broadcaster.cycle
            sleep 0.1
          }
          Thread.stop
        }
      rescue Timeout::Error
        puts 'server timeout error'
      rescue => ex
        puts "EX: #{ex}, #{ex.class}"
      end
    }
    t
  }
  # must start these after broadcaster
  let(:writer) { SimpleClient.new host, port }
  let(:writer2) { SimpleClient.new host, port }
  let(:reader) { SimpleClient.new host, port }
  let(:reader2) { SimpleClient.new host, port }

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
    broadcaster.instance_eval do
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

  it "broadcasts to ever reader on the channel" do
    writer.puts "test_channel"
    reader.puts "test_channel"
    reader2.puts "test_channel2"
    sleep 0.3
    writer.puts "test_msg"
    reader.gets.should == "test_msg"
    reader2.gets.should == nil
    writer.gets.should == nil
  end
end
