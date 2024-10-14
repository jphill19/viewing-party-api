class TmdbSerializer
  def self.format_top_rated(json)
    formatted_movies = json[:results].map do |movie|
      {
        id: movie[:id],
        type: "movie",
        attributes: {
          title: movie[:title],
          vote_average: movie[:vote_average]
        }
      }
    end
  end

  def self.format_show_movie(movie)
    {
      id: movie.id,
      type: "movie",
      attributes: {
        title: movie.title,
        release_year: movie.release_year,
        vote_average: movie.vote_average,
        runtime: movie.runtime,
        genres: movie.genres,
        summary: movie.summary,
        cast: movie.cast,
        total_reviews: movie.total_reviews,
        reviews: movie.reviews
      }
    }
  end
end