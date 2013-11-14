require 'local_config'
require "rest-client"
require 'pp'

class MqttPanic
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
  end

  def call(player)
    @player = player

    @player.register_event :mqtt_panic do
      mqtt_panic!
    end
  end


  def mqtt_panic!

# first we need to know what was originally playing
        playlist = @player.playlist
        position = @player.playlist.position
        tracks = playlist.tracks[position + 1] #(plus 1 because of the idents I think?)
        stream_url = tracks.file
        arr = stream_url.split("_") #not ideal but...
        puts "station id is #{arr[2]}"

# they are all the same ids as mqtt ones except for 5livesportsextra / 5sportxtra
        station_id = arr[2]
        if(station_id == "5sportxtra")
          station_id = "5livesportsextra"
        end

# get everything from /music that isn't an ident
# shouldn't be hardcoded
        files = []

        Dir.foreach("/music") {|x| 
          if(!x.match("ident") && x!="." && x!="..")
            files.push(x)
          end
        }

        files = files.sample(20) # a random bunch

        all_tracks = nil
        files.each do |f|
          if(!all_tracks)
            all_tracks = (Radiodan::Playlist.new( tracks: f)).tracks
          end
          all_tracks = all_tracks + (Radiodan::Playlist.new( tracks: f)).tracks
        end


        #file = "totd_20130924-0600a.mp3"
        #mp3 = Radiodan::Playlist.new tracks: file
        #all_tracks = mp3.tracks + mp31.tracks + mp32.tracks + mp33.tracks
        begin
          @player.playlist = Radiodan::Playlist.new(tracks: all_tracks, volume: @player.playlist.volume)
        rescue Exception=>e
          puts "barf"
          puts e
        end
# now we need to monitor the correct file

        file_change_time = nil
         timer = EM::Synchrony.add_periodic_timer(1) do
           file = station_id
           filename = File.join(@path, file)
           if(File.exists?(filename))
puts "!!!!!!!! #{filename} ok"
           else
puts "!!!!!!!! #{filename} NOT ok"
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
                @player.playlist = Radiodan::Playlist.new(tracks: playlist.tracks, volume: @player.playlist.volume, position: position)
              end
           end
        end
  end
end

