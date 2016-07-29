json.set! :video do
  json.extract! @video, :id, :name, :description, :url, :taken_at, :created_at, :updated_at
  json.album_ids @video.albums.pluck(:id).uniq
end
