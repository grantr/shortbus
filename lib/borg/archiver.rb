require 'leveldb'
require 'fileutils'

module Borg
  class Archiver
    include Celluloid
    include Celluloid::Notifications

    STORE_PATH = "/tmp/borg"

    def initialize
      ensure_store_path
      @databases = {}
      subscribe(/stream.*/, :store)
    end

    def store(stream, txn)
      stream_id = stream.sub(/^stream\./, '')
      db = get_db_handle(stream_id)
      seq = txn.first[:seq] #TODO
      db.put(seq.to_s, MultiJson.dump(txn))
    end

    def get_db_handle(stream_id)
      @databases[stream_id] ||= LevelDB::DB.new(File.join(STORE_PATH, stream_id))
    end

    def ensure_store_path
      FileUtils.mkdir_p(STORE_PATH)
    end
  end
end
