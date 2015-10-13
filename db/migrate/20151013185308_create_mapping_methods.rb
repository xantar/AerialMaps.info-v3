class CreateMappingMethods < ActiveRecord::Migration
  def change
    create_table :mapping_methods do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
