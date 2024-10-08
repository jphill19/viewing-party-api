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
end