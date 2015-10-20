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
      t.datetime :generated_at
      t.boolean :queued, default: false
      t.boolean :processing, default: false
      t.boolean :complete, default: false
      t.boolean :public, default: false
      t.boolean :gallery, default: false

      t.timestamps null: false
    end
  end
end
