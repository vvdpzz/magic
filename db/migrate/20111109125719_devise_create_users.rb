class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      
      t.string :name, :default => ""
      t.string :avatar, :default => ""
      t.string :about_me, :default => ""
      
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      
      t.decimal :credit, :precision => 8, :scale => 2, :default => 0
      t.integer :reputation, :default => 0
      
      t.integer :questions_count, :default => 0
      t.integer :answers_count, :default  => 0
      t.integer :comments_count, :default => 0

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    add_index :users, :authentication_token, :unique => true
  end
end
