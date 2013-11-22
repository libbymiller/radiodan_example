require 'local_config'
require "rest-client"
require 'pp'

class MqttPanic
  include Radiodan::Logging

  def initialize(config)
    @root = config[:root]
    @path = config[:path]
    @music_dir = config[:music_dir]
  end

  def call(player)
    @player = player

    @player.register_event :mqtt_panic do
      mqtt_panic!
    end
  end


  def mqtt_panic!
        playlist = @player.adapter.playlist
        index = @player.adapter.playlist.position

        tracks = @player.adapter.playlist.tracks

# first we need to know what was originally playing

        stream_url = tracks[index].file
        arr = stream_url.split("_") #not ideal but...
        puts "station id is #{arr[2]}"

# they are all the same ids as mqtt ones except for 5livesportsextra / 5sportxtra
        station_id = arr[2]
        if(station_id == "5sportxtra")
          station_id = "5livesportsextra"
        end
        if(station_id == "asiannet")
          station_id = "asiannetwork"
        end


        if(station_id)

# this hsould probably happen elsewhere so that we can return to the place we were at
# get everything from /music that isn't an ident
          files = []

          Dir.foreach(@music_dir) {|x| 
            if(!x.match("ident") && x!="." && x!="..")
              files.push(x)
            end
          }

          files = files.sample(20) # a random bunch

          all_tracks = []
          files.each do |f|
            all_tracks.push(Radiodan::Track.new file: f)
          end

          begin
            @player.playlist = Radiodan::Playlist.new(tracks: all_tracks, volume: @player.playlist.volume, random: true, repeat: true)
          rescue Exception=>e
            puts "barf"
            puts e
          end
# now we need to monitor the correct file


          monitor_file(station_id, @player, tracks, index)
        else
          # we are already avoiding. skip to next track,but continue to monitor the file
           begin
             @player.next
#             filename = File.join(@root, "station")
#             recovered_station_id = File.read(filename)
#             monitor_file(recovered_station_id, @player, tracks, index)
           rescue   
             puts "can't find recovered station id"
           end
        end
  end
end


def monitor_file(station_id, player, tracks, index)

          file_change_time = nil
          timer = EM::Synchrony.add_periodic_timer(1) do

             file = station_id
             filename = File.join(@path, file)
             if(File.exists?(filename))
             else
                File.open(filename, 'w') {|f| f.write(Time.now) }
             end
             f = File.new(filename)
             logger.debug "file change time is #{f.ctime}"
             if(!file_change_time)
                file_change_time = f.ctime
             else
                if(file_change_time < f.ctime)
                  logger.debug "file has changed #{f.ctime}***\n\n"   
                  timer.cancel
                  logger.debug "Timer cancelled\n\n"   
                  player.playlist = Radiodan::Playlist.new(tracks: tracks, volume: player.playlist.volume, position: index-1 )
                end
             end
          end
end
