json.album do
  json.extract! album, :id, :name, :position, :average_date, :created_at, :updated_at, :photos_count, :videos_count
end
