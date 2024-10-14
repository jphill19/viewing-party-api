class RemoveFieldNameFromEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :movie_time, :datetime
  end
end
