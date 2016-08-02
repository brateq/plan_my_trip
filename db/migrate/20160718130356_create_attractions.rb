class CreateAttractions < ActiveRecord::Migration
  def change
    create_table :attractions do |t|
      t.string :name
      t.string :category
      t.string :link
      t.float :latitude
      t.float :longitude
      t.float :stars
      t.boolean :visited, default: false

      t.timestamps null: false
    end
  end
end
