class CreateFollowedQuestions < ActiveRecord::Migration
  def change
    create_table :followed_questions do |t|
      t.references :user
      t.references :question
      t.boolean :status, :default => true

      t.timestamps
    end
    add_index :followed_questions, :user_id
    add_index :followed_questions, :question_id
  end
end
