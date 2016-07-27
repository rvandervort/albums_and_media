json.album do
  json.extract! @album, :id, :name, :position, :average_date, :created_at, :updated_at, :photos_count
  json.photos @photos, partial: 'photos/photo', as: :photo
end

