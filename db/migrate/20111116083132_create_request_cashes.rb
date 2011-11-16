class CreateRequestCashes < ActiveRecord::Migration
  def change
    create_table :request_cashes, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      t.integer :user_id, :limit => 8, :null => false
      t.decimal :credit, :precision => 8, :scale => 2, :default => 0
      t.integer :status, :default => 0
      t.timestamps
    end
  end
end
