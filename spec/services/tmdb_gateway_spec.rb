require 'rails_helper'

RSpec.describe TmdbGateway, type: :service do
  before do
    @tmdb_gateway = TmdbGateway.new
  end

  describe 'Initialization' do
    it 'initializes a new instance of TmdbGateway' do
      expect(@tmdb_gateway).to be_a(TmdbGateway)
    end
  end

  describe '#top_rated' do
    context 'when no query is provided' do
      it 'fetches the top-rated movies' do
        VCR.use_cassette("tmdb_top_rated_movies") do
          result = @tmdb_gateway.top_rated

          expect(result).to be_a(Hash)
          expect(result[:results]).to be_an(Array)
          expect(result[:results].count).to eq(20)
          expect(result[:results].first).to have_key(:title)
          expect(result[:results].first).to have_key(:vote_average)
        end
      end
    end

    context 'when a query is provided' do
      it 'fetches the movies based on the query' do
        query = "Inception"

        VCR.use_cassette("tmdb_search_inception") do
          result = @tmdb_gateway.top_rated(query)

          expect(result).to be_a(Hash)
          expect(result[:results]).to be_an(Array)
          expect(result[:results].count).to eq(8)
          expect(result[:results].first[:title]).to eq("Inception")
        end
      end
    end
  end

  describe '#movie_details' do
    context 'when a valid movie ID is provided' do
      it 'fetches the movie details' do
        VCR.use_cassette("tmdb_movie_details") do
          result = @tmdb_gateway.movie_details(278)

          expect(result).to be_a(Hash)
          expect(result[:title]).to be_a(String)
          expect(result[:overview]).to be_a(String)
          expect(result[:release_date]).to be_a(String)
          expect(result[:runtime]).to be_an(Integer)
          expect(result[:genres]).to be_an(Array)
          expect(result[:vote_average]).to be_a(Float)
          expect(result[:vote_count]).to be_an(Integer)
          expect(result[:production_companies]).to be_an(Array)
          expect(result[:production_countries]).to be_an(Array)
          expect(result[:spoken_languages]).to be_an(Array)
          expect(result[:status]).to be_a(String)
          expect(result[:tagline]).to be_a(String).or be_nil
          expect(result[:poster_path]).to be_a(String).or be_nil
          expect(result[:backdrop_path]).to be_a(String).or be_nil
          expect(result[:budget]).to be_an(Integer)
          expect(result[:revenue]).to be_an(Integer)
        end
      end
    end
  end

  describe '#movie_cast' do
    context 'when a valid movie ID is provided' do
      it 'fetches the movie cast' do
        VCR.use_cassette("tmdb_movie_cast") do
          result = @tmdb_gateway.movie_cast(278)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:cast)
          expect(result[:cast]).to be_an(Array)
          expect(result[:cast].first).to have_key(:name)
          expect(result[:cast].first).to have_key(:character)
        end
      end
    end
  end

  describe '#movie_reviews' do
    context 'when a valid movie ID is provided' do
      it 'fetches the movie reviews' do
        VCR.use_cassette("tmdb_movie_reviews") do
          result = @tmdb_gateway.movie_reviews(278) 

          expect(result).to be_a(Hash)
          expect(result).to have_key(:results)
          expect(result[:results]).to be_an(Array)
          expect(result[:results].first).to have_key(:author)
          expect(result[:results].first).to have_key(:content)
        end
      end
    end
  end

  describe '#show_action' do
    context 'when a valid movie ID is provided' do
      it 'returns a MovieData object' do
        VCR.use_cassette('tmdb_show_action_valid') do
          movie_details_data = {
            id: 278,
            title: 'The Shawshank Redemption',
            release_date: '1994-09-23',
            vote_average: 8.707,
            runtime: 142,
            genres: [{ id: 18, name: 'Drama' }, { id: 80, name: 'Crime' }],
            overview: 'Imprisoned in the 1940s for the double murder of his wife and her lover...'
          }
          movie_cast_data = {
            cast: [
              { name: 'Tim Robbins', character: 'Andy Dufresne' },
              { name: 'Morgan Freeman', character: 'Ellis Boyd "Red" Redding' }
            ]
          }
          movie_reviews_data = {
            total_results: 2,
            results: [
              { author: 'John Doe', content: 'Amazing movie!' },
              { author: 'Jane Smith', content: 'A timeless classic.' }
            ]
          }

          allow(@tmdb_gateway).to receive(:movie_details).and_return(movie_details_data)
          allow(@tmdb_gateway).to receive(:movie_cast).and_return(movie_cast_data)
          allow(@tmdb_gateway).to receive(:movie_reviews).and_return(movie_reviews_data)

          result = @tmdb_gateway.show_action(278)

          expect(result).to be_a(MovieData)
        end
      end
    end

    context 'when an invalid movie ID is provided' do
      it 'returns an error message' do
        VCR.use_cassette('tmdb_show_action_invalid') do
          allow(@tmdb_gateway).to receive(:movie_details).and_return({
            success: false,
            status_message: 'Invalid id: The pre-requisite id is invalid or not found.'
          })

          result = @tmdb_gateway.show_action(-1) #

          expect(result).to eq('Invalid id: The pre-requisite id is invalid or not found.')
        end
      end
    end
  end
  
  describe '.return_runtime_if_data_is_valid' do
    context 'when valid data is provided' do
      it 'returns the movie runtime' do
        VCR.use_cassette('tmdb_valid_movie') do
          data = {
            'movie_id' => 278,          
            'movie_name' => 'The Shawshank Redemption'
          }

          result = TmdbGateway.return_runtime_if_data_is_valid(data)

          expect(result).to be_an(Integer)
          expect(result).to eq(142)  
        end
      end
    end

    context 'when the movie ID does not exist' do
      it 'returns an error message' do
        VCR.use_cassette('tmdb_invalid_movie_id') do
          data = {
            'movie_id' => 0,          
            'movie_name' => 'Nonexistent Movie'
          }

          result = TmdbGateway.return_runtime_if_data_is_valid(data)
 
          expect(result).to be_a(ErrorMessage)
          expect(result.message).to eq("Can't find a movie with that id")
          expect(result.status_code).to eq(400)
        end
      end
    end

    context 'when the movie name does not match the movie ID' do
      it 'returns an error message' do
        VCR.use_cassette('tmdb_movie_name_mismatch') do
          data = {
            'movie_id' => 278,          
            'movie_name' => 'Incorrect Movie Name'
          }

          result = TmdbGateway.return_runtime_if_data_is_valid(data)
         
          expect(result).to be_a(ErrorMessage)
          expect(result.message).to eq("The name of the movie doesn't match that Id")
          expect(result.status_code).to eq(400)
        end
      end
    end
  end

end