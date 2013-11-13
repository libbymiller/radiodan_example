# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'

require 'rest_client'
require 'json'
require 'time'
require 'pp'


links = {}
downloads = []
titles = []

urls = {} # add podcast urls here from the BBC site

urls.each do |url, category|
  sleep 2
  doc = Nokogiri::HTML(open(url))

  fs_by_date = {}
  fs_by_stage = {}

  noks = []
  count = 0
  doc.css('li').each do |item|
    if(item.css('h3')[0])
      title = item.css('h3')[0].content
      dat = item.css('p.pc-episode-date')[0].content
      desc = item.css('p.pc-episode-description')[0].content
      desc = desc.gsub("\n", " ")
      desc = desc.gsub("\r", " ")
      l = item.css('p.pc-episode-cta')[0]
      desc = desc.gsub("\r", " ")
      l = item.css('p.pc-episode-cta')[0]
      link =  l.css('a').attr('href').to_s
      puts "#{link}\t#{dat}\t#{title}\t#{desc}\t#{category}"
      links[link]={"link"=>link,"date"=>dat, "title"=>title, "description"=>desc, "category"=>category}
      downloads.push(link)
      titles.push("#{title} #{link}")
    end
  end
end

puts titles.length

