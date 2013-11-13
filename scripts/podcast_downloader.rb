# encoding: UTF-8
require 'rubygems'
#require 'nokogiri'
require 'open-uri'

require 'rest_client'
require 'json'
require 'time'
require 'pp'
require 'net/http'


f = File.readlines("totd.txt")

f.each do |line|
  puts line
  arr = line.split("\t")
  url = arr[0]
  u = url.gsub("http://downloads.bbc.co.uk","")
  fn = url.gsub(/.*\//,"")

  puts "downloading #{url}, #{u}, #{fn}"

  sleep 2
  Net::HTTP.start("downloads.bbc.co.uk") do |http|
    resp = http.get(u)
    open("/music/#{fn}", "wb") do |file|
        file.write(resp.body)
    end
  end
  puts "Done."

  sleep 60
end


