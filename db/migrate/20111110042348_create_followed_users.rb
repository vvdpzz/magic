class CreateFollowedUsers < ActiveRecord::Migration
  def change
    create_table :followed_users do |t|
      t.integer :user_id, :limit => 8, :primary => true
      t.integer :follower_id, :limit => 8, :primary => true
      t.boolean :flag, :default => true

      t.timestamps
    end
    add_index :followed_users, :user_id
    add_index :followed_users, :follower_id
  end
end
