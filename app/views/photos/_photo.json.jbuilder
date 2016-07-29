json.photo do
  json.extract! photo, :id, :name, :description, :url, :taken_at, :created_at, :updated_at
end
