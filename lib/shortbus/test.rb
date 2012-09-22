require 'shortbus/group'
require 'shortbus/collector'
b = Shortbus::Collector.new("0.0.0.0", 3000)
p = Shortbus::Pusher.supervise("0.0.0.0", 3010)
Shortbus::Group.run!
