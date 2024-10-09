class User < ApplicationRecord
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: { require: true }
  has_secure_password
  has_secure_token :api_key

  has_many :event_invitations, dependent: :destroy
  has_many :events, through: :event_invitations

end