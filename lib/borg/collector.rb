require 'reel/app'

module Borg
  class Collector
    include Reel::App
    
    get "/foo" do |request|
      [200, {}, "hello foo"]
    end

  end
end
