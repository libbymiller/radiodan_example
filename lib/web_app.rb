require 'radiodan/sinatra'

class WebApp < Radiodan::Sinatra
  get '/' do
    "<h1>Radiodan</h1><p>#{CGI.escapeHTML(player.state.current.inspect)}</p>"
  end

  get '/search/:query' do
    query = params[:query]
    
    search = player.search(query)
    player.playlist = Radiodan::Playlist.new mode: :random, tracks: search
    "<h1>Radiodan</h1><p>#{CGI.escapeHTML(search.inspect)}</p>"
  end
  
  get '/play.mp3' do
    search = player.search(:filename => 'Ween/Chocolate and Cheese/10 Voodoo Lady.mp3')
    player.playlist = Radiodan::Playlist.new mode: :resume, tracks: search  
    "<h1>Radiodan</h1><p>#{CGI.escapeHTML(player.state.inspect)}</p>"
  end

  get '/next' do
    player.trigger_event :next_channel
    "Next!"
  end

  get '/prev' do
    player.trigger_event :prev_channel
    "Prev!"
  end

  get '/lower_volume/:diff' do
    player.trigger_event :lower_volume
    "Lowering Volume! #{params[:diff]}"
  end

  get '/higher_volume/:diff' do
    player.trigger_event :higher_volume
    "Increasing Volume!  #{params[:diff]}"
  end

  get '/panic' do
    player.trigger_event :mqtt_panic
    "MQQT-based panic in progress"
  end

end
