class AddMediaCountsToAlbum < ActiveRecord::Migration
  def change
    add_column :albums, :photos_count, :integer
    add_column :albums, :videos_count, :integer

    Album.reset_column_information


    #  album.restore_[model]_counts! and reset_counter
    #  don't work in the has_many :through, with polymorphic association
    Album.find_each do |album|
      album.photos_count = album.photos.count
      album.videos_count = album.videos.count
      album.save
    end
  end
end
