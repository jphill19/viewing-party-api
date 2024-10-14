class MovieData
  attr_reader :id, :title, :release_year, :vote_average, :runtime, :genres, :summary, :cast, :total_reviews, :reviews

  def initialize(movie_details, credit_details, reviews_details)
    @id = movie_details[:id]
    @title = movie_details[:title]
    @release_year = Date.parse(movie_details[:release_date]).year
    @vote_average = movie_details[:vote_average]
    @runtime = convert_minutes_to_runtime(movie_details[:runtime])
    @genres = movie_details[:genres].map { |genre| genre[:name] }
    @summary = movie_details[:overview]
    @cast = format_cast(credit_details[:cast])
    @total_reviews = reviews_details[:total_results]
    @reviews = format_reviews(reviews_details[:results])
  end

  private

  def convert_minutes_to_runtime(minutes)
    time = Time.new(0) + (minutes * 60)
    hours = time.hour
    remaining_minutes = time.min
    "#{hours} hours, #{remaining_minutes} minutes"
  end

  def format_cast(cast)
    cast.first(10).map { |member| { character: member[:character], actor: member[:name] } }
  end

  def format_reviews(reviews)
    reviews.first(5).map { |review| { author: review[:author], review: review[:content] } }
  end
end