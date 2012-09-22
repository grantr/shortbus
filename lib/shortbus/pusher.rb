require 'reel'
require 'multi_json'

module Shortbus
  class Pusher
    include Celluloid
    include Celluloid::Notifications

    def initialize(host, port)
      @connections = Hash.new { |h, k| h[k] = [] }
      @server = Reel::Server.supervise host, port do |connection|
        if connection.request
          request = connection.request
          if request.url =~ /\/streams\/([A-Za-z0-9_\-]+)/
            stream_id = $1
            @connections[stream_id] << connection
            connection.respond :ok, :transfer_encoding => :chunked
          else
            connection.respond :not_found
          end
        end
      end

      subscribe(/stream.*/, :debug)
      subscribe(/stream.*/, :push)
    end

    def push(stream_topic, txn)
      stream_id = stream_topic.sub(/^stream\./, '')
      @connections[stream_id].each do |conn|
        puts "sending #{MultiJson.dump(txn)} to #{stream_id} consumers"
        begin
          conn << "#{MultiJson.dump(txn)}\n"
        rescue IOError
          puts "closed stream"
          @connections[stream_id].delete(conn)
        end
      end
    end

    def debug(stream_topic, txn)
      puts "received txn from #{stream_topic}: #{txn}"
    end

  end
end
