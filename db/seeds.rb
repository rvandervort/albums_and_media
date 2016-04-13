# Create 10 users
3.times do |user_index|
  user = User.create(name: Faker::Name.name, email: Faker::Internet.email)

  5.times do |album_index|
    album = user.albums.create(name: Faker::Lorem.word.capitalize, position: album_index)

    40.times do |photo_index|
      album.photos.create(
        user: user,
        name: Faker::Lorem.word.capitalize,
        description: Faker::Lorem.sentence,
        url: Faker::Avatar.image(SecureRandom.hex, '50x50', 'jpg'),
        taken_at: Time.now - rand(100).days
      )
    end
  end
end
