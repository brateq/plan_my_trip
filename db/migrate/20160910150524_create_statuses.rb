class CreateStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :statuses do |t|
      t.integer :wanna_go
      t.boolean :visited
      t.references :user
      t.references :attraction

      t.timestamps
    end
  end
end
