class ChangeChannel
  include Radiodan::Logging

  def initialize(config)
    @filename = config[:filename]
  end

  def call(player)
    @player = player

    @player.register_event :change_channel do
      change_channel!
    end
  end

  def change_channel!

    EM.defer \
      proc {
        contents = File.read(@filename)
        contents = contents.chomp
        arr = contents.split("\t")
        new_channel = arr[0]
        url = arr[1]
        logger.debug "changing channel to #{new_channel}, #{url}..."
        playlist = Radiodan::Playlist.new tracks: url
        @player.playlist = playlist
        @player.trigger_event(:channel_changed)
      },
      proc {
      }

  end

end

