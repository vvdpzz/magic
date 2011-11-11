class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions, :id => false do |t|
      t.integer :id, :limit => 8, :primary => true
      t.integer :user_id, :limit => 8, :null => false
      t.string :title, :null => false
      t.text :content, :null => false
      
      t.string :rules_list, :default => ""
      t.string :customized_rule, :default => ""
      
      t.decimal :credit, :precision => 8, :scale => 2, :default => 0
      t.integer :reputation, :default => 0
      
      t.boolean :is_free, :default => false
      
      t.integer :end_date, :default => 0
      
      t.integer :votes_count, :default => 0
      t.integer :answers_count, :default  => 0
      t.integer :comments_count, :default => 0
      t.integer :correct_answer_id, :limit => 8, :default => 0
      t.integer :followed_questisons_count, :default => 0
      t.timestamps
    end
    add_index :questions, :user_id
  end
end
