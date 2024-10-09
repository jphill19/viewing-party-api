require "rails_helper"

describe "Movies API", type: :request do
  describe "#index action" do
    context "request is valid" do
      it "returns 200 and provides top 20 rated movies" do
        VCR.use_cassette("beatles_artist_query") do
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
    end
  end
end