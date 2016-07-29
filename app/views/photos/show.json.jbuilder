json.set! :photo do
  json.extract! @photo, :id, :name, :description, :url, :taken_at, :created_at, :updated_at
  json.album_ids @photo.albums.pluck(:id)
end
