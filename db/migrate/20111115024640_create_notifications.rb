class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      t.integer :user_id, :limit => 8, :null => false
      t.string :content
      t.boolean :is_read

      t.timestamps
    end
  end
end
