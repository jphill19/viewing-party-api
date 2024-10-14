require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'Associations' do
    it { should have_many(:event_invitations).dependent(:destroy) }
    it { should have_many(:users).through(:event_invitations) }
  end
  
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:movie_title) }
    it { should validate_presence_of(:api_key) }
    it { should validate_presence_of(:movie_id) }
    it { should validate_presence_of(:movie_length) }


    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_length_of(:movie_title).is_at_most(255) }

    it { should validate_numericality_of(:movie_id).only_integer }
    it { should validate_numericality_of(:movie_length).is_greater_than_or_equal_to(0) }

    it 'is invalid if start_time is not a valid datetime' do
      event = Event.new(start_time: 'invalid datetime', end_time: Time.current + 2.hours, movie_length: 120)
      event.valid?
      expect(event.errors[:start_time]).to include('must be a valid datetime')
    end

    it 'is invalid if end_time is not a valid datetime' do
      event = Event.new(start_time: Time.current + 1.hour, end_time: 'invalid datetime', movie_length: 120)
      event.valid?
      expect(event.errors[:end_time]).to include('must be a valid datetime')
    end

    it 'is invalid if start_time is in the past' do
      event = Event.new(start_time: Time.current - 1.day, end_time: Time.current + 2.hours, movie_length: 120)
      event.valid?
      expect(event.errors[:start_time]).to include("can't be in the past")
    end

    it 'is invalid if end_time is in the past' do
      event = Event.new(start_time: Time.current + 1.hour, end_time: Time.current - 1.day, movie_length: 120)
      event.valid?
      expect(event.errors[:end_time]).to include("can't be in the past")
    end

    it 'is invalid if duration is shorter than movie_length' do
      event = Event.new(
        start_time: Time.current + 1.hour,
        end_time: Time.current + 2.hours,
        movie_length: 180
      )
      event.valid?
      expect(event.errors[:base]).to include('The duration between start time and end time must be at least 180 minutes')
    end

    it 'is invalid if start_time or end_time is not valid or movie_length is missing' do
      event = Event.new(start_time: 'invalid', end_time: 'invalid', movie_length: nil)
      event.valid?
      expect(event.errors[:base]).to include('Start time and end time must be valid datetimes, and movie length must be present')
    end

    it 'is valid with correct start_time, end_time, and movie_length' do
      event = Event.new(
        name: 'Sample Event',
        start_time: Time.current + 1.hour,
        end_time: Time.current + 4.hours,
        movie_title: 'Sample Movie',
        api_key: 'some_api_key',
        movie_id: 1,
        movie_length: 180
      )
      expect(event).to be_valid
      expect(event).to be_valid
    end
  end
end