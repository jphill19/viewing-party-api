class Event < ApplicationRecord
  has_many :event_invitations, dependent: :destroy
  has_many :users, through: :event_invitations
end