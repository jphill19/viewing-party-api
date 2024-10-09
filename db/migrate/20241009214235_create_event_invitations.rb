class CreateEventInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :event_invitations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_invitations, [:event_id, :user_id], unique: true
  end
end
