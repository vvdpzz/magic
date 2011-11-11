class CreateCreditTransactions < ActiveRecord::Migration
  def change
    create_table :credit_transactions do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.integer :winner_id, :limit => 8, :default => 0
      t.integer :question_id, :limit => 8, :null => false
      t.integer :answer_id, :limit => 8, :null => false
      t.decimal :value, :precision => 8, :scale => 2, :default => 0.00
      t.boolean :payment, :default => true
      t.integer :trade_type, :default => 0
      t.integer :trade_status, :default => 0
      t.timestamps
    end
    add_index :credit_transactions, :user_id
    add_index :credit_transactions, :winner_id
    add_index :credit_transactions, :question_id
    add_index :credit_transactions, :answer_id
  end
end
