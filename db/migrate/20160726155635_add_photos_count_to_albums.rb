class AddPhotosCountToAlbums < ActiveRecord::Migration
  def up
    add_column :albums, :photos_count, :integer, default: 0

    say_with_time "Updating album photo counts..." do
      Album.find_each do |album|
        say "#{album.id} Updating photo count"
        Album.reset_counters(album.id, :photos)
      end
    end
  end

  def down
    remove_column :albums, :photos_count
  end
end
