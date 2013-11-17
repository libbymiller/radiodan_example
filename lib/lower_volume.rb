require 'local_config'
require "rest-client"
require 'pp'

class LowerVolume
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
  end

  def call(player)
    @player = player

    @player.register_event :lower_volume do
      lower_volume!
    end
  end


  def lower_volume!
        volume = @player.playlist.volume
        lower_volume = volume.to_i - 10
        puts "vol was #{volume} - volume is now #{lower_volume}"

# save volume
        filename = @path
        File.open(filename, 'w') {|f| f.write(lower_volume) }

        begin
          @player.playlist.volume = lower_volume

        rescue Exception=>e
          puts "barf"
          puts e
        end
  end
end

