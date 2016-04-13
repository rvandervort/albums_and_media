class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.integer :position
      t.date :average_date

      t.timestamps null: false
    end
  end
end
