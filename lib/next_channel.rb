require 'local_config'
require "rest-client"
require 'pp'

class NextChannel
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
    @stations = config[:stations]
    @stations_keys_sorted = config[:stations_keys_sorted]
  end

  def call(player)
    @player = player

    @player.register_event :next_channel do
      next_channel!
    end
  end

  def next_channel!
     index = @player.adapter.playlist.position
     puts "index is #{index}"
     if(index + 1 >= @stations_keys_sorted.length * 2)
       next_int = 0
     end
     puts "index was #{index} next_int #{next_int}"

     next_station_id = @stations_keys_sorted[index.to_i - 1/2]
     next_station = @stations[next_station_id]
     puts "next: #{next_station}"

# save station
     filename = @path                   
     File.open(filename, 'w') {|f| f.write(next_station_id) }

     begin
       if(next_int == 0)
          @player.play(0)
       else
         @player.next
       end
     rescue Exception=>e
       puts "barf"
       puts e
     end

     puts "player new index #{@player.playlist.position}"

  end
end

