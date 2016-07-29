json.album do
  json.extract! @album, :id, :name, :position, :average_date, :created_at, :updated_at

  json.photos_count @photos.count
  json.videos_count @videos.count

  json.photos @photos, partial: 'photos/photo', as: :photo
  json.videos @videos, partial: 'videos/video', as: :video
end

