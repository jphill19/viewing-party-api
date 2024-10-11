class EventSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :start_time, :end_time, :movie_id, :movie_title, :api_key

  has_many :users,  serializer: UserSerializer
end
