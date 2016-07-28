class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.references :album, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.string :url
      t.datetime :taken_at

      t.timestamps null: false
    end


    add_column :albums, :videos_count, :integer, default: 0

    say_with_time "Updating album video counts..." do
      Album.find_each do |album|
        say "#{album.id} Updating video count"
        Album.reset_counters(album.id, :videos)
      end
    end
  end
end
