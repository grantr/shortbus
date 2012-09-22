require 'celluloid'
require 'shortbus/sequencer'
require 'shortbus/digester'
require 'shortbus/pusher'
require 'shortbus/file_persister'
require 'shortbus/snapshotter'

module Shortbus
  class Group < Celluloid::SupervisionGroup
    supervise Sequencer, as: :sequencer
    supervise Digester, as: :digester
    #supervise Pusher, as: :pusher, args: ['0.0.0.0', 3001]
    supervise FilePersister, as: :persister
    supervise Snapshotter, as: :snapshotter
  end
end
