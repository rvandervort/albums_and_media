json.album do
  json.extract! album, :id, :name, :position, :average_date, :created_at, :updated_at
  json.photos_count album.photos.count
  json.videos_count album.videos.count
end
