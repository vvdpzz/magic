class AddFavoriteQuestionsCountToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :favorite_questions_count, :integer, :default => 0
  end
end
