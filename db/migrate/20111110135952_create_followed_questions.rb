class CreateFollowedQuestions < ActiveRecord::Migration
  def change
    create_table :followed_questions do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.integer :question_id, :limit => 8, :null => false
      t.boolean :status, :default => true
      t.timestamps
    end
    add_index :followed_questions, :user_id
    add_index :followed_questions, :question_id
  end
end
