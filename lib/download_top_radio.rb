=begin
Downloads the top things and stashes them in a file
=end

require "rest-client"
require 'pp'
require 'json'

class DownloadTopRadio

  STATIONS_MAPPING = {"bbc_radio_one" => "1", "bbc_1xtra"=>"1x","bbc_radio_two" => 
"2","bbc_radio_three"=>"3","bbc_radio_four"=>"4","bbc_radio_four_extra"=>"4x",
"bbc_radio_fourlw"=>"4lw","bbc_radio_five_live"=>"5l","bbc_radio_five_live_sports_extra"=>"5lsp",
"bbc_6music"=>"6"}

  flux = {}

  attr_accessor :stations, :url
# returns ordered list of most popular stations, top first

  def initialize(url)
    @url = url
  end

  def run
    @stations = []
    stations_hash = {}

    RestClient.proxy = ENV['HTTP_PROXY']
    puts "URL #{@url}"
    req = RestClient.get(@url)
    s = JSON.parse(req.to_s)
    stats =  s["stations"]
    stats.each do |k,v|
        if(k)
           v.each do |vv|
             stations_hash[k]=vv["audience"]["total"]
           end
        end
    end
    stations_hash = stations_hash.sort_by {|_key, value| value}
    stations_hash.each do |s|
       new_name = STATIONS_MAPPING[s[0]]
       if(new_name)
         @stations.push("bbc_radio_#{new_name}")
       end
    end
    @stations = @stations.reverse
    if(@stations.length==0)

       @stations  = [
"bbc_radio_1",
"bbc_radio_2",
"bbc_radio_6",
"bbc_radio_4",
"bbc_radio_5l",
"bbc_radio_1x",
"bbc_radio_3",
"bbc_radio_4x",
"bbc_radio_5lsp",
"bbc_radio_4lw"]
    end
    @stations
  end
end

#d = DownloadTopRadio.new
#pp d.run

