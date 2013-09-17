require 'rspec'
require_relative '../app'

describe SimpleBroadcaster do
  it "broadcasts what one client sends back out to all clients" do
    simple_broadcaster.bind 'localhost', 32134
    `echo "test_one" > nc 127.0.0.1 31234`
  end
end
