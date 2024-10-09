class MovieSerializer
  include JSONAPI::Serializer
  set_id :id
  attributes :title, :vote_average
end