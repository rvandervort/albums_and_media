class AddIndexToAlbumPosition < ActiveRecord::Migration
  def change
    add_index :albums, :position
  end
end
