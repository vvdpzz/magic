class AddLockedCreditToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locked_credit, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
