require 'celluloid'
require 'borg/sequencer'
require 'borg/digester'
require 'borg/pusher'

module Borg
  class Group < Celluloid::SupervisionGroup
    supervise Sequencer, as: :sequencer
    supervise Digester, as: :digester
    supervise Pusher, as: :pusher
  end
end