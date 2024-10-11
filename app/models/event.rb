class Event < ApplicationRecord
  has_many :event_invitations, dependent: :destroy
  has_many :users, through: :event_invitations
  validates :name, presence: true, length: { maximum: 255 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :movie_title, presence: true, length: { maximum: 255 }
  validates :api_key, presence: true
  validates :movie_id, presence: true, numericality: { only_integer: true }
  validates :movie_length, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :start_time_must_be_valid_datetime
  validate :end_time_must_be_valid_datetime
  validate :start_time_cannot_be_in_the_past
  validate :end_time_cannot_be_in_the_past
  validate :duration_must_be_longer_than_movie_length
  
  private
  
  def start_time_must_be_valid_datetime
    errors.add(:start_time, 'must be a valid datetime') unless valid_datetime?(start_time)
  end
  
  def end_time_must_be_valid_datetime
    errors.add(:end_time, 'must be a valid datetime') unless valid_datetime?(end_time)
  end
  
  def valid_datetime?(datetime)
    datetime.is_a?(Time) || datetime.is_a?(ActiveSupport::TimeWithZone)
  end
  
  def start_time_cannot_be_in_the_past
    if valid_datetime?(start_time) && start_time < Time.current
      errors.add(:start_time, "can't be in the past")
    end
  end
  
  def end_time_cannot_be_in_the_past
    if valid_datetime?(end_time) && end_time < Time.current
      errors.add(:end_time, "can't be in the past")
    end
  end

  def duration_must_be_longer_than_movie_length
    if valid_datetime?(start_time) && valid_datetime?(end_time) && movie_length.present?
      duration_in_minutes = (end_time - start_time) / 60.0
  
      if duration_in_minutes < movie_length
        errors.add(:base, "The duration between start time and end time must be at least #{movie_length} minutes")
      end
    else
      errors.add(:base, 'Start time and end time must be valid datetimes, and movie length must be present')
    end
  end
  

end

