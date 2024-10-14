class AddMovieLengthToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :movie_length, :integer
  end
end
