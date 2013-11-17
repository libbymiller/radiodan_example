require 'local_config'
require "rest-client"
require 'pp'

class HigherVolume
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
  end

  def call(player)
    @player = player

    @player.register_event :higher_volume do
      higher_volume!
    end
  end


  def higher_volume!
        higher_volume = @player.playlist.volume.to_i + 10
        puts "volume is now #{higher_volume}"

# save volume
        filename = @path                   
        File.open(filename, 'w') {|f| f.write(higher_volume) }

        begin
          @player.playlist.volume = higher_volume
        rescue Exception=>e
          puts "barf"
          puts e
        end
  end
end

