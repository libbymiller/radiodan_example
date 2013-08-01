require 'json'
require 'faye'
require 'eventmachine'

class WebServer < Sinatra::Base
  register Sinatra::Async

  use Faye::RackAdapter, :mount => '/faye', :timeout => 25
  #bayeux.listen(8000)



  def initialize(player)
    @player = player
    Faye::WebSocket.load_adapter('thin')
    client = Faye::Client.new("http://localhost:3000/faye")
    @player.register_event :channel_changed do
      puts "channel changed!!!!!!"
      state = @player.state
      volume = @player.playlist.volume
      name = @player.playlist.tracks[0]["Name"]
      client.publish("/foo", "Channel Changed to #{state}, #{volume}, #{name}")
    end

    super()
  end

  aget '/' do
    EM::Synchrony.next_tick do
      body { "<h1>Radiodan</h1><p>#{CGI.escapeHTML(@player.state.inspect)}</p>" }
    end
  end

  get '/test' do
    erb :test
  end


  aget '/panic' do
    @player.trigger_event :panic
    body "Panic!"
  end
end
