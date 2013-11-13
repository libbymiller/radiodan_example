require 'local_config'
require "rest-client"
require 'pp'

class PrevChannel
  include Radiodan::Logging

  def initialize(config)
    @stations = config[:stations]
    @stations_keys_sorted = config[:stations_keys_sorted]
    @titles = config[:titles]
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
    @player.register_event :prev_channel do
      prev_channel!
    end
  end


  def prev_channel!

     index = @player.playlist.position
     puts "index is #{index}"
     prev_int = (index - 2 < 0) ? (@stations_keys_sorted.length * 2) - 2 : index - 2

     puts "prev_int #{prev_int}"
     prev_station_id = @stations_keys_sorted[prev_int.to_i]
     prev_station = @stations[prev_station_id]
     puts "prev channel #{prev_int} #{@stations_keys_sorted.length}  #{prev_station_id}"
     title = @titles[prev_station_id]

     begin
       @player.playlist = Radiodan::Playlist.new(tracks: @player.playlist.tracks, volume: @player.playlist.volume, position: prev_int)
     rescue Exception=>e
       puts "barf"
       puts e
     end
     puts "player new index #{@player.playlist.position}"

  end
end

