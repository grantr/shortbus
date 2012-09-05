require 'celluloid'
require 'borg/sequencer'
require 'borg/digester'
require 'borg/pusher'
require 'borg/archiver'
require 'borg/snapshotter'

module Borg
  class Group < Celluloid::SupervisionGroup
    supervise Sequencer, as: :sequencer
    supervise Digester, as: :digester
    #supervise Pusher, as: :pusher, args: ['0.0.0.0', 3001]
    supervise Archiver, as: :archiver
    supervise Snapshotter, as: :snapshotter
  end
end
