class CreateAttractions < ActiveRecord::Migration
  def change
    create_table :attractions do |t|
      t.string :name
      t.string :category
      t.string :link
      t.float :latitude
      t.float :longitude
      t.string :continent
      t.string :country
      t.string :region
      t.string :province
      t.string :municipality
      t.string :city
      t.string :island_group
      t.string :island
      t.float :stars
      t.integer :reviews
      t.boolean :visited, default: false

      t.timestamps null: false
    end
  end
end
