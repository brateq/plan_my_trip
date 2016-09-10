class RemoveStatusFromAttractions < ActiveRecord::Migration[5.0]
  def change
    remove_column :attractions, :status, :string
  end
end
