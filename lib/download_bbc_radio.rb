=begin
In order to fake a radio, we need to stream radio content.
BBC Radio streams are playlist files, which contain
a link to a time-restricted audio stream.

Every few hours, the stream disconnects and you have to 
download the playlist again to continue.

This downloads the playlists and parses for the audio end point.
=end

require "radiodan/playlist"
require "rest-client"

class DownloadBBCRadio
  URL = "http://www.bbc.co.uk/radio/listen/live/r%s_aaclca.pls"
  STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6 an}
  METADATA = ["Radio one", "Radio One Extra", "Radio Two", "Radio Three", "Radio Four F M ", "Radio Four Long Wave", "Radio Four Extra", "Radio Five Live", "Radio Five Live Sports Extra", "Radio Six Music", "Asian Network"]
  attr_accessor :stations, :titles


  def run
    @stations ||= Hash.new
    @titles ||= Hash.new
    @threads = []
    
    RestClient.proxy = ENV['HTTP_PROXY']

# gather titlles while no threading
    count = 0
    STATIONS.each do |station|
        station_name = "bbc_radio_#{station}"
        puts "metadata #{METADATA[count]}"
        @titles[station_name] = METADATA[count]
        count = count+1
    end

    STATIONS.each do |station|
      @threads << Thread.new do 
        req = RestClient.get(URL % station)
        next if req.nil?

        url = req.match(/^File1=(.*)$/)[1]

        station_name = "bbc_radio_#{station}"

        if(url)
#          content = Radiodan::Playlist.new tracks: url
          content = url
        end
        @stations[station_name] = content
      end
    end

    @threads.collect(&:join)
    @stations
  end
end
