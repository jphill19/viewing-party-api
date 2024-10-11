class AddMovieTimeToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :movie_time, :datetime
  end
end
