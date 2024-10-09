class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.integer :movie_id
      t.string :movie_title
      t.string :api_key

      t.timestamps
    end
  end
end
