STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6}
METADATA = ["Radio one", "Radio One Extra", "Radio Two", "Radio Three", "Radio Four F M ", "Radio Four Long Wave", "Radio Four Extra", "Radio Five Live", "Radio Five Live Sports Extra", "Radio Six Music"]

count = 0
STATIONS.each do |station|
  station_name = "bbc_radio_#{station}"
  title = METADATA[count]
  `espeak -v en "Channel is now #{title}" --stdout > "/music/#{station_name}.wav"`
  count = count + 1
  sleep 2
end

