module Borg
  class Sequencer
    include Celluloid

    attr_reader :counter

    def initialize
      @counters = Hash.new { |h, k| h[k] = 0 }
    end

    def push(stream, txn)
      @counters[stream] += 1
      Actor[:digester].push(stream, { seq: @counters[stream], changes: Array(txn)})
    end
  end
end
