class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      t.integer :user_id, :limit => 8, :null => false
      t.integer :magic_id, :limit => 8, :null => false
      t.string :name, :null => false
      t.text :content, :null => false

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :magic_id
  end
end
