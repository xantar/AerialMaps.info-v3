class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :image_uid
      t.string :user_id
      t.string :image_name
      t.integer :map_id
      t.string :camera
      t.float :gps_latitude
      t.float :gps_longitude
      t.string :taken_at

      t.timestamps null: false
    end
  end
end
