class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :title
      t.string :image_uid
      t.string :thumbnail_uid
      t.string :latitude
      t.string :longitude
      t.string :bearing
      t.string :camera
      t.string :mapping_method_id
      t.string :taken_at
      t.string :user_id
	  t.integer :status
	  t.boolean :failed, defauilt: false
      
      t.boolean :queued, default: false
      t.datetime :queued_at
      t.boolean :processing, default: false
      t.datetime :generated_at
      t.boolean :complete, default: false
      t.boolean :public, default: false
      t.boolean :gallery, default: false
      t.boolean :public_gps, default: false
      t.boolean :gallery_gps, default: false

      t.timestamps null: false
    end
  end
end
