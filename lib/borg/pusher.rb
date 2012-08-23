module Borg
  class Pusher
    include Celluloid
    include Celluloid::Notifications

    def initialize
      subscribe(/stream.*/, :debug)
    end

    def debug(stream, txn)
      puts "received txn from #{stream}: #{txn}"
    end

  end
end
