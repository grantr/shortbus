module Shortbus
  class Sequencer
    include Celluloid

    #TODO get last seq # from persister
    def initialize
      @counters = Hash.new { |h, k| h[k] = 0 }
    end

    def get(stream)
      @counters[stream] += 1
    end
  end
end
