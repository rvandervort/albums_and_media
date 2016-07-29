class CreateContentLists < ActiveRecord::Migration
  def up
    create_table :content_lists do |t|
      t.integer :album_id
      t.integer :asset_id
      t.string :asset_type
      t.timestamps null: false
    end

    add_index :content_lists, [:album_id, :asset_type, :asset_id]


    say_with_time "Migrating existing photos to m:n" do
      Photo.find_each do |photo|
        ContentList.create(album_id: photo.album_id, asset: photo)
      end
    end

    say_with_time "Migrating existing videos to m:n" do
      Video.find_each do |video|
        ContentList.create(album_id: video.album_id, asset: video)
      end
    end

    say_with_time "Removing :album_id from photos, videos" do
      remove_column :photos, :album_id
      remove_column :videos, :album_id
    end

    say_with_time "Removing counter caches from albums" do
      remove_column :albums, :photos_count
      remove_column :albums, :videos_count
    end
  end

  def down
    say "Adding :album_id back to photos, videos"

    add_column :photos, :album_id, :integer
    add_column :videos, :album_id, :integer

    say "Adding counter caches to albums"

    add_column :albums, :photos_count, :integer
    add_column :albums, :videos_count, :integer

    say_with_time "Setting each photo's album to the first in the list" do
      # Assumes the m:n association still exists in the Photo
      # model. otherwise photos.albums won't work!
      Photo.reset_column_information
      Photo.find_each do |photo|
        photo.album_id = photo.albums.first.id
        photo.save
      end
    end


    say_with_time "Setting each video's album to the first in the list" do
      # Same for videos
      Video.reset_column_information
      Video.find_each do |video|
        video.album_id = video.albums.first.id
      end
    end

    drop_table :content_lists
  end
end
