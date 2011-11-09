class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.string :image
      t.string :salt

      t.timestamps
    end
    add_index :photos, :user_id
  end
end
