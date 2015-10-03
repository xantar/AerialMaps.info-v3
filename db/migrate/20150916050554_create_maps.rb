class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :title
      t.string :image_uid
      t.string :thumbnail_uid
      t.string :image_name
      t.string :latitude
      t.string :longitude
      t.string :camera
      t.string :map_mode
      t.string :taken_at
      t.string :user_id
      t.boolean :complete

      t.timestamps null: false
    end
  end
end
