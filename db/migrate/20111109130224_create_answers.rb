class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      t.integer :user_id, :limit => 8, :null => false
      t.integer :question_id, :limit => 8, :null => false
      t.text :content, :null => false
      
      t.boolean :is_correct, :default => false
      
      t.integer :votes_count, :default => 0
      t.integer :comments_count, :default => 0

      t.timestamps
    end
    add_index :answers, :user_id
    add_index :answers, :question_id
  end
end
