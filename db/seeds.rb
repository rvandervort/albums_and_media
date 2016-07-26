# Populate albums and photos
10.times do |album_index|
  album = Album.create(name: Faker::Lorem.word.capitalize, position: album_index)

  10.times do |photo_index|
    album.photos.create(
      name: Faker::Lorem.word.capitalize,
      description: Faker::Lorem.sentence,
      url: Faker::Avatar.image(SecureRandom.hex, '50x50', 'jpg'),
      taken_at: Time.now - rand(100).days
    )
  end
end
