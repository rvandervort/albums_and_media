class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :name
      t.integer :position
      t.date :average_date

      t.timestamps null: false
    end
  end
end
