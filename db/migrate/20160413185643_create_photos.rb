class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.references :album, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.string :url
      t.datetime :taken_at

      t.timestamps null: false
    end
  end
end
