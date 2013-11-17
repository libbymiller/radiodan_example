require 'local_config'
require "rest-client"
require 'pp'

class PrevChannel
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
    @stations = config[:stations]
    @stations_keys_sorted = config[:stations_keys_sorted]
    @titles = config[:titles]
  end

  def call(player)
    @player = player

    @player.register_event :prev_channel do
      prev_channel!
    end
  end


  def prev_channel!

     index = @player.adapter.playlist.position
     puts "index is #{index} adapter is #{@player.adapter.playlist.position}"

     # complexity here is the idents, which are so short they don't count but we want to hear them
     prev_int = (index - 2 < 0) ? (@stations_keys_sorted.length * 2) - 1 : index - 3

     puts "prev_int #{prev_int}"
     prev_station_id = @stations_keys_sorted[prev_int.to_i/2]
     prev_station = @stations[prev_station_id]
     puts "prev channel #{prev_int} #{@stations_keys_sorted.length}  #{prev_station_id}"
     title = @titles[prev_station_id]

# save station
     filename = @path
     File.open(filename, 'w') {|f| f.write(prev_station_id) }

     begin
       @player.play(prev_int)
     rescue Exception=>e
       puts "barf"
       puts e
     end
     puts "player new index #{@player.playlist.position}"

  end
end

