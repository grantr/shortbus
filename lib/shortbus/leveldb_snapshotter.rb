require 'leveldb'
require 'fileutils'

module Shortbus
  class LeveldbSnapshotter
    include Celluloid

    STORE_PATH = "/tmp/shortbus/snapshots"

    def initialize
      ensure_store_path
      #TODO set timer
    end

    def create_snapshot(stream, last_seq=nil)
      last_seq ||= Actor[:archiver].last_seq_for(stream)
      return unless last_seq

      snapshot_db = database_for(stream, last_seq)

      #TODO get most recent snapshot, add it to db
      #TODO if a db exists from the previous snapshot, use that instead of creating
      # a new one
      #TODO only use leveldb if size is large. otherwise hash is more efficient

      first_seq = nil
      
      # apply deltas since previous snapshot seq
      Actor[:archiver].deltas_for(stream, from: first_seq, to: last_seq).each do |seq, json|
        txn = MultiJson.load(json)
        changes = txn.first['changes']
        changes.each do |change|
          type, record = change
          snapshot_db.put "#{type},#{record['id']}", MultiJson.dump(record)
        end
      end
      
      # generate new snapshot
      snapshot_file = File.new(File.join(STORE_PATH, "snapshot-#{stream}-#{last_seq}"), "w")
      #TODO write header
      snapshot_db.each do |k, v|
        type, id = k.split(",")
        snapshot_file.puts MultiJson.dump({ type => MultiJson.load(v) })
        #TODO digests
      end

      snapshot_file.close
      snapshot_db.close
    end

    private

    def database_for(stream, seq)
      LevelDB::DB.new(File.join(STORE_PATH, "#{stream}-#{seq}"))
    end

    def ensure_store_path
      FileUtils.mkdir_p(STORE_PATH)
    end
  end
end
