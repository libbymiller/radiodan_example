require 'local_config'
require "rest-client"
require 'pp'

class LowerVolume
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
    @player.register_event :lower_volume do
      lower_volume!
    end
  end


  def lower_volume!
        volume = @player.playlist.volume
        lower_volume = volume.to_i - 10
        puts "vol was #{volume} - volume is now #{lower_volume}"
        begin
          @player.playlist = Radiodan::Playlist.new(tracks: @player.playlist.tracks, volume: lower_volume, position: @player.playlist.position)
        rescue Exception=>e
          puts "barf"
          puts e
        end
  end
end

