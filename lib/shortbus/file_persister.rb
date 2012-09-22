require 'fileutils'

module Shortbus
  class FilePersister
    include Celluloid
    include Celluloid::Notifications

    STORE_PATH = "/tmp/shortbus/streams"

    def initialize
      ensure_store_path
      @databases = {}
      @last_seq = {}
      subscribe(/stream\.incoming\./, :store)
    end

    def store(stream_topic, txn)
      stream = stream_topic.sub(/^stream\.incoming\./, '')
      db = database_for(stream)
      @last_seq[stream] = txn[:seq].to_s
      db.puts MultiJson.dump(txn)
      publish("stream.outgoing.#{stream}", txn)
    end

    def last_seq_for(stream)
      @last_seq[stream] #TODO 
    end

    def deltas_for(stream, options={})
      database_for(stream).each(options)
    end

    def database_for(stream)
      #TODO this should start at the beginning, json load every record, and
      #store the last seq
      @databases[stream] ||= File.new(File.join(STORE_PATH, stream), "a")
    end

    def finalize
      @databases.values.each(&:close)
    end

    private

    def ensure_store_path
      FileUtils.mkdir_p(STORE_PATH)
    end
  end
end
