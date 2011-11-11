class CreateFavoriteQuestions < ActiveRecord::Migration
  def change
    create_table :favorite_questions do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.integer :question_id, :limit => 8, :null => false
      t.boolean :status, :default => true

      t.timestamps
    end
    add_index :favorite_questions, :user_id
    add_index :favorite_questions, :question_id
  end
end
