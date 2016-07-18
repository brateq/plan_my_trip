class CreateAttractions < ActiveRecord::Migration
  def change
    create_table :attractions do |t|
      t.string :name
      t.string :type
      t.string :link
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end
