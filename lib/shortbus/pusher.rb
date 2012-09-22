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

      subscribe(/^stream\.outgoing\./, :push)
    end

    def push(stream_topic, txn)
      stream = stream_topic.sub(/^stream\.outgoing\./, '')
      puts "received txn from #{stream}: #{txn}"
      @connections[stream].each do |connection|
        puts "sending #{MultiJson.dump(txn)} to #{stream} consumer #{connection}"
        begin
          connection << "#{MultiJson.dump(txn)}\n"
        rescue IOError
          puts "closed stream"
          @connections[stream].delete(connection)
        end
      end
    end

  end
end
