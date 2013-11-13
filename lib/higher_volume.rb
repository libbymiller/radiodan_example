require 'local_config'
require "rest-client"
require 'pp'

class HigherVolume
  include Radiodan::Logging

  def initialize(config)
  end

  def call(player)
    @player = player

    @player.register_event :play_state do |state|
      if(state == :stop)
        puts "state is stop"
      else
        puts "state is not stop"
      end
    end
    @player.register_event :higher_volume do
      higher_volume!
    end
  end


  def higher_volume!
        higher_volume = @player.playlist.volume.to_i + 10
        puts "volume is now #{higher_volume}"
        begin
          @player.playlist = Radiodan::Playlist.new(tracks: @player.playlist.tracks, volume: higher_volume, position: @player.playlist.position)
        rescue Exception=>e
          puts "barf"
          puts e
        end
  end
end

