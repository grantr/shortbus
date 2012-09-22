require 'reel/app'
require 'openssl'
require 'multi_json'

module Shortbus
  class Collector
    include Reel::App
    include Celluloid::Notifications

    SECRET = "895f258089dac96c0feae216e5a40c4153c4853a"
    
    # /streams/vote
    post "/streams/:id" do |request|
      #TODO authentication
      stream_hash = OpenSSL::HMAC.hexdigest('sha1', SECRET, request.path[:id])
      [301, { 'Location' => "/streams/#{request.path[:id]}/#{stream_hash}" }, ""]
    end

    # /streams/vote/e914gadf41
    post "/streams/:id/:key" do |request|
      if request.path[:key] == OpenSSL::HMAC.hexdigest('sha1', SECRET, request.path[:id])
        sequence = Celluloid::Actor[:sequencer].future(:get, request.path[:id])
        txn = request.input.read
        if valid_txn?(txn)
          seq = sequence.value
          publish("stream.incoming.#{request.path[:id]}", build_delta(seq, txn))
          [201, {}, seq]
        else
          [400, {}, "Invalid transaction"]
        end
      else
        [401, {}, ""]
      end
    end

    #TODO add a Transaction class instead of passing around arrays
    def build_delta(seq, txn)
      {
        seq: seq,
        changes: [MultiJson.load(txn)] #TODO support multiple changes in a transaction
      }
    end

    # [ "type", "id", { "record": "value" }]
    # [ "type", "id", "non-hash value"]
    # [ "type", "id", { "__delete": true }]
    # [[ "type", "id", { "record": "value" }], ... ]
    #
    # TODO should also support transactions without types or ids:
    # [ "type", null, some_value ]
    # [ null, null, some_value ]
    # these streams would not be snapshot-able.
    def valid_txn?(txn)
      begin
        case txn
        when String
          valid_txn?(MultiJson.load(txn))
        when Array
          if txn.first.is_a?(Array)
            txn.all? { |t| valid_txn?(t) }
          else
            txn.size == 3 && 
              txn[0].is_a?(String) && 
              txn[1].is_a?(String)
          end
        else
          false
        end
      rescue MultiJson::DecodeError
        false
      end
    end

  end
end
