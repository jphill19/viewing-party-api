require "rails_helper"

describe "Events API", type: :request do
  before(:each) do
    @user = User.create!(name: "Tom", username: "myspace_creator", password: "test123")
    @invitee1 = User.create!(name: "Oprah", username: "oprah", password: "abcqwerty")
    @invitee2 = User.create!(name: "Beyonce", username: "sasha_fierce", password: "blueivy")
    @invitee3 = User.create!(name: "Ben Stiller", username: "severance", password: "iwantseason2out")
  end
  
  describe "Create Action" do
    context "when request is valid" do
      it "creates a new event and returns 201" do
        valid_event_params = {
          "name" => "Juliet's Bday Movie Bash!",
          "start_time" => "2025-02-01 10:00:00",
          "end_time" => "2025-02-01 14:30:00",
          "movie_id" => 278, 
          "movie_title" => "The Shawshank Redemption",
          "api_key" => @user.api_key,
          "invitees" => [@invitee1.id, @invitee2.id,]
        }

        VCR.use_cassette("tmdb_valid_movie") do
          headers = {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
    
          post "/api/v1/events", params: valid_event_params.to_json, headers: headers
        end
       
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body, symbolize_names: true)

        expected_invitees = [
          {
            id: @invitee1.id.to_s,
            type: "user",
          },
          {
            id: @invitee2.id.to_s,
            type: "user",
          }
        ]

        data = json_response[:data]
        attributes = data[:attributes]
        relationship = data[:relationships][:users][:data]
   
        expect(data[:id]).to eq(Event.last.id.to_s)
        expect(data[:type]).to eq("event")
        
        expect(attributes[:name]).to eq(Event.last.name)
        expect(attributes[:start_time]).to eq(Event.last.start_time.iso8601(3))
        expect(attributes[:end_time]).to eq(Event.last.end_time.iso8601(3))
        expect(attributes[:movie_id]).to eq(Event.last.movie_id)
        expect(attributes[:movie_title]).to eq(Event.last.movie_title)
        expect(relationship).to match_array(expected_invitees)
      end
    end

    context "when some invitees do not exist" do
      it "returns 422 and error message" do
      
        invalid_invitee_id = 99999  

        invalid_invitees = [@invitee1.id, invalid_invitee_id]
        invalid_params = {
          "name" => "Sample Event",
          "start_time" => (Time.current + 1.day),
          "end_time" => (Time.current + 1.day + 3.hours),
          "movie_title" => "The Shawshank Redemption",
          "api_key" => @user.api_key,
          "movie_id" => "278",
          "movie_name" => "The Shawshank Redemption",
          "invitees" => invalid_invitees
        }

        VCR.use_cassette("tmdb_valid_movie") do
          headers = {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
    
          post "/api/v1/events", params: invalid_params.to_json, headers: headers
        end

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body, symbolize_names: true)
       
        expect(json_response[:message]).to eq('Some invitees do not exist')
        expect(json_response[:status]).to eq(422)
      end
    end

    context "when movie runtime cannot be retrieved" do
      it "returns error message and appropriate status code" do
        invalid_movie_id = "0" 

        invalid_params = {
          "name" => "Sample Event",
          "start_time" => (Time.current + 1.day),
          "end_time" => (Time.current + 1.day + 3.hours),
          "movie_title" => "Invalid Movie",
          "api_key" => @user.api_key,
          "movie_id" => invalid_movie_id,
          "movie_name" => "Invalid Movie",
          "invitees" => [@invitee1.id, @invitee2.id]
        }

        VCR.use_cassette("tmdb_invalid_movie_id") do
          headers = {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
    
          post "/api/v1/events", params: invalid_params.to_json, headers: headers
        end

        expect(response).to have_http_status(400)
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to eq("Can't find a movie with that id")
        expect(json_response[:status]).to eq(400)
      end
    end

    context "when event fails to save due to validation errors (no name)" do
      it "returns validation errors and 422 status" do
        invalid_params = {
          "start_time" => (Time.current + 1.day),
          "end_time" => (Time.current + 1.day + 3.hours),
          "movie_title" => "The Shawshank Redemption",
          "api_key" => @user.api_key,
          "movie_id" => "278",
          "movie_name" => "The Shawshank Redemption",
          "invitees" => [@invitee1.id, @invitee2.id]
        }

        VCR.use_cassette("tmdb_valid_movie") do
          headers = {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
    
          post "/api/v1/events", params: invalid_params.to_json, headers: headers
        end

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Name can't be blank")
        expect(json_response[:status]).to eq(422)
      end
    end

    context "when the api key doesn't matching users" do
      it "returns validation errors and 422 status" do
        invalid_params = {
          "name" => "Sample Event",
          "start_time" => (Time.current + 1.day),
          "end_time" => (Time.current + 1.day + 3.hours),
          "movie_title" => "The Shawshank Redemption",
          "api_key" => "bad key",
          "movie_id" => "278",
          "movie_name" => "The Shawshank Redemption",
          "invitees" => [@invitee1.id, @invitee2.id]
        }

        VCR.use_cassette("tmdb_valid_movie") do
          headers = {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
    
          post "/api/v1/events", params: invalid_params.to_json, headers: headers
        end

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Invalid login credentials")
        expect(json_response[:status]).to eq(401)
      end
    end
  end


  describe "add_user action" do
    before (:each) do
      @event = Event.create!(
        name: "Juliet's Bday Movie Bash!",
        start_time: "2025-02-01 10:00:00",
        end_time: "2025-02-01 14:30:00",
        movie_id: 278,
        movie_length: 142,
        movie_title: "The Shawshank Redemption",
        api_key: @user.api_key
      )

      @event_inv_1 = EventInvitation.create!(
        event: @event,
        user: @invitee1
      )
      @event_inv_2 = EventInvitation.create!(
        event: @event,
        user: @invitee2
      )
    end

    context "when request is valid" do
      it "creates a new event and returns 200" do
        valid_params = {
          api_key: @user.api_key,        
          invitees_user_id: @invitee3.id  
        }

        patch "/api/v1/events/#{@event.id}/add_user", params: valid_params
        json_response = JSON.parse(response.body, symbolize_names: true)

        expected_invitees = [
          {
            id: @invitee1.id.to_s,
            type: "user",
          },
          {
            id: @invitee2.id.to_s,
            type: "user",
          },
          {
            id: @invitee3.id.to_s,
            type: "user",
          },
        ]

        expect(response).to have_http_status(:ok)

        data = json_response[:data]
        attributes = data[:attributes]
        relationship = data[:relationships][:users][:data]
   
        expect(data[:id]).to eq(@event.id.to_s)
        expect(data[:type]).to eq("event")
        
        expect(attributes[:name]).to eq(@event.name)
        expect(attributes[:start_time]).to eq(@event.start_time.iso8601(3))
        expect(attributes[:end_time]).to eq(@event.end_time.iso8601(3))
        expect(attributes[:movie_id]).to eq(@event.movie_id)
        expect(attributes[:movie_title]).to eq(@event.movie_title)
        expect(relationship).to match_array(expected_invitees)
      end
    end

    context "when request is invalid" do
      it "returns 401 when api_key doesnt match" do
        invalid_params = {
          api_key: 123,        
          invitees_user_id: @invitee3.id  
        }
        patch "/api/v1/events/#{@event.id}/add_user", params: invalid_params
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Invalid login credentials")
        expect(json_response[:status]).to eq(401)
      end

      it "returns 404 when user doesnt exist" do
        bad_id = @invitee3.id + 1 
        invalid_params = {
          api_key: @user.api_key,        
          invitees_user_id: bad_id
        }
        patch "/api/v1/events/#{@event.id}/add_user", params: invalid_params
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Couldn't find User with 'id'=#{bad_id}")
        expect(json_response[:status]).to eq(404)
      end

      it "returns __ when viewing party doesnt exist" do
        bad_event_id = @event.id + 1
        invalid_params = {
          api_key: @user.api_key,        
          invitees_user_id: @invitee3.id
        }
        patch "/api/v1/events/#{bad_event_id}/add_user", params: invalid_params
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Couldn't find Event with 'id'=#{bad_event_id}")
        expect(json_response[:status]).to eq(404)
      end

      it "returns ___ when user has already been added to the viewing party" do
        invalid_params = {
          api_key: @event.api_key,        
          invitees_user_id: @invitee2.id  
        }
        patch "/api/v1/events/#{@event.id}/add_user", params: invalid_params
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:message]).to include("Duplicate record: This record already exist")
        expect(json_response[:status]).to eq(409)
      end
    end
  end
end
