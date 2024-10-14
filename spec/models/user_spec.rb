require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:password) }
    it { should have_secure_password }
    it { should have_secure_token(:api_key) }
    it { should have_many(:event_invitations).dependent(:destroy) }
    it { should have_many(:events).through(:event_invitations) }
  end

  before do
    @user1 = User.create!(
      name: "Me",
      username: "its_me",
      password: "QWERTY123",
      password_confirmation: "QWERTY123"
    )

    @invite1 = User.create!(
      name: "Mario",
      username: "wahoo",
      password: "QWERTY123",
      password_confirmation: "QWERTY123"
    )

    @invite2 = User.create!(
      name: "Luigi",
      username: "wehee",
      password: "QWERTY123",
      password_confirmation: "QWERTY123"
    )

    @event = Event.create!(
      name: "Juliet's Bday Movie Bash!",
      start_time: "2025-02-01 10:00:00",
      end_time: "2025-02-01 14:30:00",
      movie_id: 278,
      movie_title: "The Shawshank Redemption",
      api_key: @user1.api_key,
      movie_length: 142
    )

    EventInvitation.create!(
      user: @user1,
      event: @event
    )

    EventInvitation.create!(
      user: @invite1,  
      event: @event
    )

    EventInvitation.create!(
      user: @invite2,
      event: @event
    )
  end

  describe "parties_invited" do
    it "will return all an event alongside the designated host_id" do
      result = @invite1.parties_invited.first
      expect(result.host_id).to eq(@user1.id) 
      expect(result.name).to eq("Juliet's Bday Movie Bash!")
    end
  end
end