json.video do
  json.extract! video, :id, :name, :description, :url, :taken_at, :created_at, :updated_at
end
