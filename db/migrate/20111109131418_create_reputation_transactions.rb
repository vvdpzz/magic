class CreateReputationTransactions < ActiveRecord::Migration
  def change
    create_table :reputation_transactions do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.integer :winner_id, :limit => 8, :default => 0
      t.integer :question_id, :limit => 8
      t.integer :answer_id, :limit => 8
      t.integer :value, :null => false, :default => 0
      t.boolean :payment, :default => true
      t.integer :trade_type, :default => 0
      t.integer :trade_status, :default => 0
      t.timestamps
    end
    add_index :reputation_transactions, :user_id
    add_index :reputation_transactions, :winner_id
    add_index :reputation_transactions, :question_id
    add_index :reputation_transactions, :answer_id
  end
end
