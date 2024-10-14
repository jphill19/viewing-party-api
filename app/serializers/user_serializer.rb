class UserSerializer
  include JSONAPI::Serializer
  attributes :name, :username
  attribute :api_key, if: proc { |_, params| !params[:exclude_api_key] }
  attribute :hosted_parties do |user, params|
    params[:hosted_parties].map(&:attributes) if params[:hosted_parties]
  end

  attribute :viewing_parties_invited, if: proc { |_, params| params[:parties_invited].present? } do |user, params|
    params[:parties_invited].map do |event|
      {
        id: event.id,
        name: event.name,
        start_time: event.start_time,
        end_time: event.end_time,
        movie_id: event.movie_id, 
        movie_title: event.movie_title,
        host_id: event.host_id
      }
    end
  end
  
  attribute :hosted_parties, if: proc { |_, params| params[:hosted_parties].present? } do |user, params|
    params[:hosted_parties].map do |event|
      {
        id: event.id,
        name: event.name,
        start_time: event.start_time,
        end_time: event.end_time,
        movie_id: event.movie_id, 
        movie_title: event.movie_title,
        host_id: params[:current_user_id]
      }
    end
  end


  def self.format_user_list(users)
    { data:
        users.map do |user|
          {
            id: user.id.to_s,
            type: "user",
            attributes: {
              name: user.name,
              username: user.username
            }
          }
        end
    }
  end

end