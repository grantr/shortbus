module Shortbus
  class Digester
    include Celluloid
    include Celluloid::Notifications

    def initialize
      @previous_digest = nil
    end

    def push(stream, txn)
      publish("stream.#{stream}", [txn, OpenSSL::Digest.hexdigest('sha1', [@previous_digest, MultiJson.dump(txn)].join)])
    end
  end
end
