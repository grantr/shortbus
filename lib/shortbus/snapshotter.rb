require 'fileutils'

module Shortbus
  class Snapshotter
    include Celluloid

    STORE_PATH = "/tmp/shortbus/snapshots"

    #TODO this should be an actor that starts and creates a snapshot immediately, then dies
    def initialize
      ensure_store_path
      #TODO set timer
    end

    def create_snapshot(stream, last_seq=nil)
      last_seq ||= Actor[:archiver].last_seq_for(stream)
      return unless last_seq

      snapshot_db = Hash.new { |h,k| h[k] = Hash.new }

      #TODO get most recent snapshot, add it to db
      #TODO if a db exists from the previous snapshot, use that instead of creating
      # a new one
      #TODO only use leveldb if size is large. otherwise hash is more efficient

      first_seq = nil
      
      # apply deltas since previous snapshot seq
      Actor[:archiver].deltas_for(stream, from: first_seq, to: last_seq).each do |seq, json|
        changes = MultiJson.load(json)
        changes.each do |change|
          type, id, record = change
          snapshot_db[type][id] = record
        end
      end
      
      # generate new snapshot
      snapshot_file = File.new(File.join(STORE_PATH, "snapshot-#{stream}-#{last_seq}"), "w")
      #TODO write header
      snapshot_db.each do |type, records|
        records.each do |id, record|
          snapshot_file.puts MultiJson.dump([type, id, record])
        end
      end

      snapshot_file.close
    end

    def ensure_store_path
      FileUtils.mkdir_p(STORE_PATH)
    end
  end
end
