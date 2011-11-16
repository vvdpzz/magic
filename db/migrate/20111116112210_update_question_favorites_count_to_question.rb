class UpdateQuestionFavoritesCountToQuestion < ActiveRecord::Migration
  def change
    change_column :questions, :favorite_questions_count, :integer, :default => 0
  end
end
