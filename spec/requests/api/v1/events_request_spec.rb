require "rails_helper"

describe "Events API", type: :request do
  describe "POST /api/v1/events" do
    before(:each) do
      @user = User.create!(name: "Tom", username: "myspace_creator", password: "test123")
      @invitee1 = User.create!(name: "Oprah", username: "oprah", password: "abcqwerty")
      @invitee2 = User.create!(name: "Beyonce", username: "sasha_fierce", password: "blueivy")
    end

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

        expected_output = {
          data: {
            id: json_response[:data][:id], 
            type: "event",
            attributes: {
              id: json_response[:data][:attributes][:id], 
              name: "Juliet's Bday Movie Bash!",
              start_time: "2025-02-01T10:00:00.000Z",
              end_time: "2025-02-01T14:30:00.000Z",
              movie_id: 278,
              movie_title: "The Shawshank Redemption",
              api_key: @user.api_key
            },
            relationships: {
              users: {
                data: [
                  { id: @invitee1.id.to_s, type: "user" },
                  { id: @invitee2.id.to_s, type: "user" },
                ]
              }
            }
          }
        }
        expect(json_response).to eq(expected_output)
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
        invalid_movie_id = "0"  # Invalid movie ID

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
  end
end
