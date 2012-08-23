require 'reel/app'
require 'openssl'
require 'multi_json'

module Borg
  class Collector
    include Reel::App

    SECRET = "895f258089dac96c0feae216e5a40c4153c4853a"
    
    get "/foo" do |request|
      [200, {}, "hello foo"]
    end

    # /streams/vote
    post "/streams/:id" do |request|
      #TODO authentication
      stream_hash = OpenSSL::HMAC.hexdigest('sha1', SECRET, request.path[:id])
      [301, { 'Location' => "/streams/#{request.path[:id]}/#{stream_hash}" }, ""]
    end

    # /streams/vote/e914gadf41
    post "/streams/:id/:key" do |request|
      if request.path[:key] == OpenSSL::HMAC.hexdigest('sha1', SECRET, request.path[:id])
        txn = request.input.read
        if valid_txn?(txn)
          Celluloid::Actor[:sequencer].push(request.path[:id], MultiJson.load(txn))
          [200, {}, ""]
        else
          [400, {}, "Invalid transaction"]
        end
      else
        [401, {}, ""]
      end
    end

    def valid_txn?(txn)
      begin
        case txn
        when String
          valid_txn?(MultiJson.load(txn))
        when Array
          txn.all? { |t| valid_txn?(t) }
        when Hash
          txn.size == 1 && txn.values.first.is_a?(Hash) && txn.values.first.has_key?('id') 
        else
          false
        end
      rescue MultiJson::DecodeError
        false
      end
    end

  end
end
