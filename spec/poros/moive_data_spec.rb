require 'rails_helper'

RSpec.describe MovieData do
  before(:each) do
    @movie_details = {
      id: 278,
      title: 'The Shawshank Redemption',
      release_date: '1994-09-23',
      vote_average: 8.707,
      runtime: 142,
      genres: [{ id: 18, name: 'Drama' }, { id: 80, name: 'Crime' }],
      overview: 'Imprisoned in the 1940s for the double murder of his wife and her lover...'
    }

    @credit_details = {
      cast: [
        { name: 'Tim Robbins', character: 'Andy Dufresne' },
        { name: 'Morgan Freeman', character: 'Ellis Boyd "Red" Redding' },
        { name: 'Bob Gunton', character: 'Warden Norton' }
      ]
    }

    @reviews_details = {
      total_results: 2,
      results: [
        { author: 'John Doe', content: 'Amazing movie!' },
        { author: 'Jane Smith', content: 'A timeless classic.' }
      ]
    }

    @movie_data = MovieData.new(@movie_details, @credit_details, @reviews_details)
  end

  describe '#initialize' do
    it 'sets the movie attributes correctly' do
      expect(@movie_data.id).to eq(278)
      expect(@movie_data.title).to eq('The Shawshank Redemption')
      expect(@movie_data.release_year).to eq(1994)
      expect(@movie_data.vote_average).to eq(8.707)
      expect(@movie_data.runtime).to eq('2 hours, 22 minutes')
      expect(@movie_data.genres).to eq(['Drama', 'Crime'])
      expect(@movie_data.summary).to eq('Imprisoned in the 1940s for the double murder of his wife and her lover...')
    end

    it 'formats the cast correctly' do
      expect(@movie_data.cast).to eq([
        { character: 'Andy Dufresne', actor: 'Tim Robbins' },
        { character: 'Ellis Boyd "Red" Redding', actor: 'Morgan Freeman' },
        { character: 'Warden Norton', actor: 'Bob Gunton' }
      ])
    end

    it 'sets the total reviews correctly' do
      expect(@movie_data.total_reviews).to eq(2)
    end

    it 'formats the reviews correctly' do
      expect(@movie_data.reviews).to eq([
        { author: 'John Doe', review: 'Amazing movie!' },
        { author: 'Jane Smith', review: 'A timeless classic.' }
      ])
    end
  end

  describe '#convert_minutes_to_runtime' do
    it 'converts runtime from minutes to hours and minutes' do
      expect(@movie_data.send(:convert_minutes_to_runtime, 142)).to eq('2 hours, 22 minutes')
    end
  end

  describe '#format_cast' do
    it 'formats the cast data correctly, limiting to 10 members' do
      more_cast = Array.new(15) { |i| { name: "Actor #{i}", character: "Character #{i}" } }
      result = @movie_data.send(:format_cast, more_cast)
      expect(result.length).to eq(10)
    end
  end

  describe '#format_reviews' do
    it 'formats the reviews data correctly, limiting to 5 reviews' do
      more_reviews = Array.new(10) { |i| { author: "Author #{i}", content: "Content #{i}" } }
      result = @movie_data.send(:format_reviews, more_reviews)
      expect(result.length).to eq(5)
    end
  end
end
