require "rails_helper"

describe "Movies API", type: :request do

  describe "#index action" do
    context "request is valid " do
      it "returns 200 and provides top 20 rated movies" do
        VCR.use_cassette("top_20_rated_movies") do
          get "/api/v1/movies"
        end
        expect(response).to be_successful
        json = JSON.parse(response.body, symbolize_names: true)
    
        expect(json[:data]).to be_an(Array)
        expect(json[:data].count).to eq(20)

        expect(json[:data].first[:id]).not_to be_nil
        expect(json[:data].first[:type]).to eq("movie")
        expect(json[:data].first[:attributes]).to have_key(:title)
        expect(json[:data].first[:attributes]).to have_key(:vote_average)
      end

      it "can handle query params, and return filtered results based on the param" do
        query = "Lord of the rings"
        encoded_query = URI.encode_www_form_component(query)

        VCR.use_cassette("filterd_movies_by_search") do
          get "/api/v1/movies?query=#{encoded_query}"
        end
        expect(response).to be_successful
        json = JSON.parse(response.body, symbolize_names: true)
    
        expect(json[:data]).to be_an(Array)
        expect(json[:data].count).to eq(20)

        expect(json[:data].first[:id]).not_to be_nil
        expect(json[:data].first[:type]).to eq("movie")
        expect(json[:data].first[:attributes]).to have_key(:title)
        expect(json[:data].first[:attributes]).to have_key(:vote_average)
      end
    end
  end

  describe "#show action" do
    context "request is valid " do
      it "returns 200 and provides details to a movie based on its id" do
        id = 278
        VCR.use_cassette("shaw_shank_redemption_details") do
          get "/api/v1/movies/#{id}"
        end
        expect(response).to be_successful
        json = JSON.parse(response.body, symbolize_names: true)

        expect(json[:data]).to be_a(Hash)
        expect(json[:data][:id]).to eq(278)
        expect(json[:data][:type]).to eq("movie")

        attributes = json[:data][:attributes]

        expect(attributes[:title]).to eq("The Shawshank Redemption")
        expect(attributes[:release_year]).to eq(1994)
        expect(attributes[:vote_average]).to eq(8.707)
        expect(attributes[:runtime]).to eq("2 hours, 22 minutes")

        expect(attributes[:genres]).to be_an(Array)
        expect(attributes[:genres].count).to eq(2)
        expect(attributes[:genres]).to include("Drama", "Crime")

        expect(attributes[:summary]).to include("Imprisoned in the 1940s")

        expect(attributes[:cast]).to be_an(Array)
        expect(attributes[:cast].count).to eq(10)
        expect(attributes[:cast].first[:character]).to eq("Andy Dufresne")
        expect(attributes[:cast].first[:actor]).to eq("Tim Robbins")

        expect(attributes[:total_reviews]).to eq(15)

        expect(attributes[:reviews]).to be_an(Array)
        expect(attributes[:reviews].count).to eq(5)
        expect(attributes[:reviews].first[:author]).to eq("elshaarawy")
        expect(attributes[:reviews].first[:review]).to include("very good movie 9.5/10")
      end
    end

    context "request is invalid " do
      it "returns 400, for imporper id" do
        id = 99999999999999999999999999999999999
        VCR.use_cassette("bad_show_id") do
          get "/api/v1/movies/#{id}"
        end
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Invalid id: The pre-requisite id is invalid or not found.")
        expect(json[:status]).to eq(400)
      end
    end
  end
end