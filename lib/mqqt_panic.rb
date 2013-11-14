require 'local_config'
require "rest-client"
require 'pp'

class MqqtPanic
  include Radiodan::Logging

  def initialize(config)
    @path = config[:path]
  end

  def call(player)
    @player = player

    @player.register_event :mqqt_panic do
      mqqt_panic!
    end
  end


  def mqqt_panic!

# first we need to know what was originally playing
        playlist = @player.playlist
        position = @player.playlist.position
        tracks = playlist.tracks[position + 1] #(plus 1 because of the idents I think?)
        stream_url = tracks.file
        arr = stream_url.split("_") #not ideal but...
        puts "station id is #{arr[2]}"

# they are all the same ids as mqqt ones except for 5livesportsextra / 5sportxtra
        station_id = arr[2]
        if(station_id == "5sportxtra")
          station_id = "5livesportsextra"
        end

        file = "totd_20130924-0600a.mp3"
        mp3 = Radiodan::Playlist.new tracks: file
        mp31 = Radiodan::Playlist.new tracks: "totd_20131031-0600a.mp3"
        mp32 = Radiodan::Playlist.new tracks: "totd_20130618-0600a.mp3"
        mp33 = Radiodan::Playlist.new tracks: "totd_20130610-0600a.mp3"
        all_tracks = mp3.tracks + mp31.tracks + mp32.tracks + mp33.tracks
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
           f = File.new(File.join(@path, file))
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

