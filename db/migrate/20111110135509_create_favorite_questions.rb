class CreateFavoriteQuestions < ActiveRecord::Migration
  def change
    create_table :favorite_questions do |t|
      t.references :user
      t.references :question
      t.boolean :status, :default => true

      t.timestamps
    end
    add_index :favorite_questions, :user_id
    add_index :favorite_questions, :question_id
  end
end
