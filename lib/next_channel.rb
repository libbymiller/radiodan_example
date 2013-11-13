require 'local_config'
require "rest-client"
require 'pp'

class NextChannel
  include Radiodan::Logging

  def initialize(config)
    @stations = config[:stations]
    @stations_keys_sorted = config[:stations_keys_sorted]
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
    @player.register_event :next_channel do
      next_channel!
    end
  end

  def next_channel!
     index = @player.playlist.position
     puts "index is #{index}"
     next_int = (index + 2 > (@stations_keys_sorted.length * 2) - 2) ? 0 : index + 2
     puts "next_int #{next_int}"
     next_station_id = @stations_keys_sorted[next_int.to_i]
     next_station = @stations[next_station_id]
     puts "next channel #{next_int} #{@stations_keys_sorted.length}  #{next_station_id}"
     begin
       @player.playlist = Radiodan::Playlist.new(tracks: @player.playlist.tracks, volume: @player.playlist.volume, position: next_int)
     rescue Exception=>e
       puts "barf"
       puts e
     end

     puts "player new index #{@player.playlist.position}"

  end
end

