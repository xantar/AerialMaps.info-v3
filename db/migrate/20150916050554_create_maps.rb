class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :title
      t.string :image_uid
      t.string :thumbnail_uid
      t.string :image_name
      t.string :latitude
      t.string :longitude
      t.string :bearing
      t.string :distance
      t.string :camera
      t.string :mapping_method_id
      t.string :taken_at
      t.string :user_id
      t.boolean :processing
      t.boolean :complete

      t.timestamps null: false
    end
  end
end
