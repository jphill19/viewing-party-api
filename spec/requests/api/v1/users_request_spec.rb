require "rails_helper"

RSpec.describe "Users API", type: :request do
  describe "Create User Endpoint" do
    let(:user_params) do
      {
        name: "Me",
        username: "its_me",
        password: "QWERTY123",
        password_confirmation: "QWERTY123"
      }
    end

    context "request is valid" do
      it "returns 201 Created and provides expected fields" do
        User.destroy_all
        post api_v1_users_path, params: user_params, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:type]).to eq("user")
        expect(json[:data][:id]).to eq(User.last.id.to_s)
        expect(json[:data][:attributes][:name]).to eq(user_params[:name])
        expect(json[:data][:attributes][:username]).to eq(user_params[:username])
        expect(json[:data][:attributes]).to have_key(:api_key)
        expect(json[:data][:attributes]).to_not have_key(:password)
        expect(json[:data][:attributes]).to_not have_key(:password_confirmation)
      end
    end

    context "request is invalid" do
      it "returns an error for non-unique username" do
        User.create!(name: "me", username: "its_me", password: "abc123")

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username has already been taken")
        expect(json[:status]).to eq(400)
      end

      it "returns an error when password does not match password confirmation" do
        user_params = {
          name: "me",
          username: "its_me",
          password: "QWERTY123",
          password_confirmation: "QWERT123"
        }

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Password confirmation doesn't match Password")
        expect(json[:status]).to eq(400)
      end

      it "returns an error for missing field" do
        user_params[:username] = ""

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username can't be blank")
        expect(json[:status]).to eq(400)
      end
    end
  end

  describe "Get All Users Endpoint" do
    it "retrieves all users but does not share any sensitive data" do
      User.destroy_all
      User.create!(name: "Tom", username: "myspace_creator", password: "test123")
      User.create!(name: "Oprah", username: "oprah", password: "abcqwerty")
      User.create!(name: "Beyonce", username: "sasha_fierce", password: "blueivy")

      get api_v1_users_path

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].count).to eq(3)
      expect(json[:data][0][:attributes]).to have_key(:name)
      expect(json[:data][0][:attributes]).to have_key(:username)
      expect(json[:data][0][:attributes]).to_not have_key(:password)
      expect(json[:data][0][:attributes]).to_not have_key(:password_digest)
      expect(json[:data][0][:attributes]).to_not have_key(:api_key)
    end
  end

  describe "show" do
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
        user: @invite1,  
        event: @event
      )
  
      EventInvitation.create!(
        user: @invite2,
        event: @event
      )
    end
    context "happy path" do
      it "returns hosted and invited parties and parties invited to successfully" do
        EventInvitation.create!(
          user: @user1,
          event: @event
        )
        headers = { 
          "Authorization" => @user1.api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json"
      }
        get "/api/v1/users/#{@user1.id}", headers: headers
  
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json_response[:data]).to be_present
        expect(json_response[:data][:id]).to eq(@user1.id.to_s)
        expect(json_response[:data][:type]).to eq("user")
        

        expect(json_response[:data][:attributes]).to be_present
        expect(json_response[:data][:attributes][:name]).to eq("Me")
        expect(json_response[:data][:attributes][:username]).to eq("its_me")
        

        expect(json_response[:data][:attributes][:hosted_parties]).to be_present
        expect(json_response[:data][:attributes][:hosted_parties].count).to eq(1)
        expect(json_response[:data][:attributes][:hosted_parties][0][:id]).to eq(@event.id)
        expect(json_response[:data][:attributes][:hosted_parties][0][:name]).to eq("Juliet's Bday Movie Bash!")
        expect(json_response[:data][:attributes][:hosted_parties][0][:start_time]).to eq("2025-02-01T10:00:00.000Z")
        expect(json_response[:data][:attributes][:hosted_parties][0][:end_time]).to eq("2025-02-01T14:30:00.000Z")
        expect(json_response[:data][:attributes][:hosted_parties][0][:movie_id]).to eq(278)
        expect(json_response[:data][:attributes][:hosted_parties][0][:movie_title]).to eq("The Shawshank Redemption")
        expect(json_response[:data][:attributes][:hosted_parties][0][:host_id]).to eq(@user1.id)
        

        expect(json_response[:data][:attributes][:viewing_parties_invited]).to be_present
        expect(json_response[:data][:attributes][:viewing_parties_invited].count).to eq(1)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:id]).to eq(@event.id)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:name]).to eq("Juliet's Bday Movie Bash!")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:start_time]).to eq("2025-02-01T10:00:00.000Z")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:end_time]).to eq("2025-02-01T14:30:00.000Z")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:movie_id]).to eq(278)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:movie_title]).to eq("The Shawshank Redemption")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:host_id]).to eq(@user1.id)
      end
      it "returns hosted only hosted parties if the user is not invited to parties" do
        headers = { 
          "Authorization" => @user1.api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json"
      }
        get "/api/v1/users/#{@user1.id}", headers: headers
  
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json_response[:data]).to be_present
        expect(json_response[:data][:id]).to eq(@user1.id.to_s)
        expect(json_response[:data][:type]).to eq("user")
        

        expect(json_response[:data][:attributes]).to be_present
        expect(json_response[:data][:attributes][:name]).to eq("Me")
        expect(json_response[:data][:attributes][:username]).to eq("its_me")
        

        expect(json_response[:data][:attributes][:hosted_parties]).to be_present
        expect(json_response[:data][:attributes][:hosted_parties].count).to eq(1)
        expect(json_response[:data][:attributes][:hosted_parties][0][:id]).to eq(@event.id)
        expect(json_response[:data][:attributes][:hosted_parties][0][:name]).to eq("Juliet's Bday Movie Bash!")
        expect(json_response[:data][:attributes][:hosted_parties][0][:start_time]).to eq("2025-02-01T10:00:00.000Z")
        expect(json_response[:data][:attributes][:hosted_parties][0][:end_time]).to eq("2025-02-01T14:30:00.000Z")
        expect(json_response[:data][:attributes][:hosted_parties][0][:movie_id]).to eq(278)
        expect(json_response[:data][:attributes][:hosted_parties][0][:movie_title]).to eq("The Shawshank Redemption")
        expect(json_response[:data][:attributes][:hosted_parties][0][:host_id]).to eq(@user1.id)
      end
      it "returns only invited parties if user is not hosting a party" do
        headers = { 
          "Authorization" => @invite1.api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json"
      }
        get "/api/v1/users/#{@invite1.id}", headers: headers
  
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json_response[:data]).to be_present
        expect(json_response[:data][:id]).to eq(@invite1.id.to_s)
        expect(json_response[:data][:type]).to eq("user")
        

        expect(json_response[:data][:attributes]).to be_present
        expect(json_response[:data][:attributes][:name]).to eq(@invite1.name)
        expect(json_response[:data][:attributes][:username]).to eq(@invite1.username)
        
        expect(json_response[:data][:attributes][:viewing_parties_invited]).to be_present
        expect(json_response[:data][:attributes][:viewing_parties_invited].count).to eq(1)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:id]).to eq(@event.id)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:name]).to eq("Juliet's Bday Movie Bash!")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:start_time]).to eq("2025-02-01T10:00:00.000Z")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:end_time]).to eq("2025-02-01T14:30:00.000Z")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:movie_id]).to eq(278)
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:movie_title]).to eq("The Shawshank Redemption")
        expect(json_response[:data][:attributes][:viewing_parties_invited][0][:host_id]).to eq(@user1.id)
      end
    end

    context "sad paths" do
      it "when user_id is invalid" do
        headers = { 
          "Authorization" => @invite1.api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json"
      }
        get "/api/v1/users/#{(User.last.id + 1)}", headers: headers
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:not_found)
        expect(json_response[:message]).to eq("Couldn't find User with 'id'=#{User.last.id + 1}")
        expect(json_response[:status]).to eq(404)
      end

      it "when api_key is invalid" do
        headers = { 
          "Authorization" => "123",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
      }
        get "/api/v1/users/#{(User.last.id)}", headers: headers
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(401)
        expect(json_response[:message]).to eq("Invalid login credentials")
        expect(json_response[:status]).to eq(401)
      end
    end
  end
end
