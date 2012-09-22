require 'leveldb'
require 'fileutils'

module Shortbus
  class LeveldbArchiver
    include Celluloid
    include Celluloid::Notifications

    STORE_PATH = "/tmp/shortbus/streams"

    def initialize
      ensure_store_path
      @databases = {}
      @last_seq = {}
      subscribe(/stream.*/, :store)
    end

    def store(stream_topic, txn)
      stream = stream_topic.sub(/^stream\./, '')
      db = database_for(stream)
      @last_seq[stream] = txn[:seq].to_s
      db.put(txn[:seq].to_s, MultiJson.dump(txn[:changes]))
    end

    def last_seq_for(stream)
      @last_seq[stream] ||= database_for(stream).keys.last
    end

    def deltas_for(stream, options={})
      database_for(stream).each(options)
    end

    def database_for(stream)
      @databases[stream] ||= LevelDB::DB.new(File.join(STORE_PATH, stream))
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
