# Viewing Part API - Solo Project

This is the base repo for the Viewing Party Solo Project for Module 3 in Turing's Software Engineering Program. 

## About this Application

Viewing Party is an application that allows users to explore movies and create a Viewing Party Event that invites users and keeps track of a host. Once completed, this application will collect relevant information about movies from an external API, provide CRUD functionality for creating a Viewing Party and restrict its use to only verified users. 

## Setup

1. Fork and clone the repo
2. Install gem packages: `bundle install`
3. Setup the database: `rails db:{drop,create,migrate,seed}`

Spend some time familiarizing yourself with the functionality and structure of the application so far.

Run the application and test out some endpoints: `rails s`

## Endpoints
### 1. Top rated movies
*GET* /api/v1/movies

- Description: Retrieves a list of the top 20 highest-rated movies of all time, based on their average vote.
- Authentication: No Authorization header required.
- Parameters: None.

**Example Request:**
```
GET /api/v1/movies
```

*Example Response:*
```
[
    {
        "id": 278,
        "type": "movie",
        "attributes": {
            "title": "The Shawshank Redemption",
            "vote_average": 8.707
        }
    },
    {
        "id": 238,
        "type": "movie",
        "attributes": {
            "title": "The Godfather",
            "vote_average": 8.691
        }
    },
    {
        "id": 240,
        "type": "movie",
        "attributes": {
            "title": "The Godfather Part II",
            "vote_average": 8.6
        }
    },
    {
        "id": 424,
        "type": "movie",
        "attributes": {
            "title": "Schindler's List",
            "vote_average": 8.564
        }
    },
    {
        "id": 389,
        "type": "movie",
        "attributes": {
            "title": "12 Angry Men",
            "vote_average": 8.545
        }
    },
    {
        "id": 129,
        "type": "movie",
        "attributes": {
            "title": "Spirited Away",
            "vote_average": 8.5
        }
    },
    {
        "id": 19404,
        "type": "movie",
        "attributes": {
            "title": "Dilwale Dulhania Le Jayenge",
            "vote_average": 8.5
        }
    },
    {
        "id": 155,
        "type": "movie",
        "attributes": {
            "title": "The Dark Knight",
            "vote_average": 8.515
        }
    },
    {
        "id": 496243,
        "type": "movie",
        "attributes": {
            "title": "Parasite",
            "vote_average": 8.506
        }
    },
    {
        "id": 497,
        "type": "movie",
        "attributes": {
            "title": "The Green Mile",
            "vote_average": 8.506
        }
    },
    {
        "id": 680,
        "type": "movie",
        "attributes": {
            "title": "Pulp Fiction",
            "vote_average": 8.5
        }
    },
    {
        "id": 372058,
        "type": "movie",
        "attributes": {
            "title": "Your Name.",
            "vote_average": 8.5
        }
    },
    {
        "id": 122,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The Return of the King",
            "vote_average": 8.482
        }
    },
    {
        "id": 13,
        "type": "movie",
        "attributes": {
            "title": "Forrest Gump",
            "vote_average": 8.472
        }
    },
    {
        "id": 429,
        "type": "movie",
        "attributes": {
            "title": "The Good, the Bad and the Ugly",
            "vote_average": 8.462
        }
    },
    {
        "id": 769,
        "type": "movie",
        "attributes": {
            "title": "GoodFellas",
            "vote_average": 8.5
        }
    },
    {
        "id": 346,
        "type": "movie",
        "attributes": {
            "title": "Seven Samurai",
            "vote_average": 8.5
        }
    },
    {
        "id": 12477,
        "type": "movie",
        "attributes": {
            "title": "Grave of the Fireflies",
            "vote_average": 8.457
        }
    },
    {
        "id": 11216,
        "type": "movie",
        "attributes": {
            "title": "Cinema Paradiso",
            "vote_average": 8.4
        }
    },
    {
        "id": 637,
        "type": "movie",
        "attributes": {
            "title": "Life Is Beautiful",
            "vote_average": 8.448
        }
    }
]
```
**Key Points:**
- No Authorization Required: This endpoint does not require an Authorization header.
- No Parameters: There are no query parameters or body data required. Simply calling the endpoint will return the top 20 highest-rated movies based on their average vote.
- Response:
  - A list of 20 movies, each with their id, title, and vote_average.
### 2. Search Movies by Query
*GET* /api/v1/movies?query=:query

- Description: Searches for movies that match the query and returns a maximum of 20 results.
- Authentication: No Authorization header required.
- Parameters:
  - query (required) - The search term to look for in the movie titles.
**Example Request:**
```
GET /api/v1/movies?query=Lord%20of%20the%20rings
```

**Example Response:**
```
[
    {
        "id": 122,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The Return of the King",
            "vote_average": 8.482
        }
    },
    {
        "id": 120,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The Fellowship of the Ring",
            "vote_average": 8.416
        }
    },
    {
        "id": 121,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The Two Towers",
            "vote_average": 8.399
        }
    },
    {
        "id": 839033,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The War of the Rohirrim",
            "vote_average": 0.0
        }
    },
    {
        "id": 123,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings",
            "vote_average": 6.587
        }
    },
    {
        "id": 1016184,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings: The Rings of Power Global Fan Screening",
            "vote_average": 7.4
        }
    },
    {
        "id": 453779,
        "type": "movie",
        "attributes": {
            "title": "A Passage to Middle-Earth: Making of 'Lord of the Rings'",
            "vote_average": 7.2
        }
    },
    {
        "id": 1090869,
        "type": "movie",
        "attributes": {
            "title": "Lord of the Rings: The Hunt for Gollum",
            "vote_average": 0.0
        }
    },
    {
        "id": 1035526,
        "type": "movie",
        "attributes": {
            "title": "Forging Through the Darkness: The Ralph Bakshi Vision for 'The Lord of the Rings'",
            "vote_average": 10.0
        }
    },
    {
        "id": 651342,
        "type": "movie",
        "attributes": {
            "title": "J.R.R. Tolkien and the Birth of \"The Lord of the Rings\" and \"The Hobbit\"",
            "vote_average": 6.0
        }
    },
    {
        "id": 945739,
        "type": "movie",
        "attributes": {
            "title": "Darla's Book Club: Discussing the Lord of the Rings",
            "vote_average": 10.0
        }
    },
    {
        "id": 296260,
        "type": "movie",
        "attributes": {
            "title": "Master of the Rings: The Unauthorized Story Behind J.R.R. Tolkien's \"Lord of the Rings\"",
            "vote_average": 9.0
        }
    },
    {
        "id": 155586,
        "type": "movie",
        "attributes": {
            "title": "Creating the Lord of the Rings Symphony",
            "vote_average": 6.8
        }
    },
    {
        "id": 1355737,
        "type": "movie",
        "attributes": {
            "title": "The Hunt for Gollum Collection",
            "vote_average": null
        }
    },
    {
        "id": 1355735,
        "type": "movie",
        "attributes": {
            "title": "Lord of the Rings: The Hunt for Gollum - Part 2",
            "vote_average": 0.0
        }
    },
    {
        "id": 1264381,
        "type": "movie",
        "attributes": {
            "title": "The Lord of the Rings the Musical - Original London Production - Promotional Documentary",
            "vote_average": 10.0
        }
    },
    {
        "id": 1361,
        "type": "movie",
        "attributes": {
            "title": "The Return of the King",
            "vote_average": 6.4
        }
    },
    {
        "id": 1362,
        "type": "movie",
        "attributes": {
            "title": "The Hobbit",
            "vote_average": 6.5
        }
    },
    {
        "id": 573089,
        "type": "movie",
        "attributes": {
            "title": "The Quest Fulfilled: A Director's Vision",
            "vote_average": 6.417
        }
    },
    {
        "id": 622231,
        "type": "movie",
        "attributes": {
            "title": "The Making of The Fellowship of the Ring",
            "vote_average": 8.9
        }
    }
]
```
**Key Points:**
- No Authorization Required: This endpoint does not require an Authorization header.
- Query Parameter:
  - query: The search term used to find movies. It is required and passed in the URL as a query string.
- Response:
  - Returns a list of up to 20 movies that match the query, with each movie's id, title, and vote_average.

### 3. Get Movie Details
*GET* /api/v1/movies/:id

- Description: Retrieves detailed information about a movie, including its cast, reviews, and summary.
- Authentication: No Authorization header required.
- Parameters:
  - id (required) - The ID of the movie to retrieve.

**Example Request:**
```
GET /api/v1/movies/278
```

**Example Response:**
```
{
    "id": 278,
    "type": "movie",
    "attributes": {
        "title": "The Shawshank Redemption",
        "release_year": 1994,
        "vote_average": 8.707,
        "runtime": "2 hours, 22 minutes",
        "genres": [
            "Drama",
            "Crime"
        ],
        "summary": "Imprisoned in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope.",
        "cast": [
            {
                "character": "Andy Dufresne",
                "actor": "Tim Robbins"
            },
            {
                "character": "Ellis Boyd 'Red' Redding",
                "actor": "Morgan Freeman"
            },
            {
                "character": "Warden Norton",
                "actor": "Bob Gunton"
            },
            {
                "character": "Heywood",
                "actor": "William Sadler"
            },
            {
                "character": "Captain Byron T. Hadley",
                "actor": "Clancy Brown"
            },
            {
                "character": "Tommy",
                "actor": "Gil Bellows"
            },
            {
                "character": "Brooks Hatlen",
                "actor": "James Whitmore"
            },
            {
                "character": "Bogs Diamond",
                "actor": "Mark Rolston"
            },
            {
                "character": "1946 D.A.",
                "actor": "Jeffrey DeMunn"
            },
            {
                "character": "Skeet",
                "actor": "Larry Brandenburg"
            }
        ],
        "total_reviews": 15,
        "reviews": [
            {
                "author": "elshaarawy",
                "review": "very good movie 9.5/10 محمد الشعراوى"
            },
            {
                "author": "John Chard",
                "review": "Some birds aren't meant to be caged.\r\n\r\nThe Shawshank Redemption is written and directed by Frank Darabont..."
            },
            {
                "author": "tmdb73913433",
                "review": "Make way for the best film ever made people. **Make way.**"
            },
            {
                "author": "thommo_nz",
                "review": "There is a reason why this movie is at the top of any popular list..."
            },
            {
                "author": "Andrew Gentry",
                "review": "It's still puzzling to me why this movie exactly continues to appear in every single best-movies-of-all-time chart..."
            }
        ]
    }
}
```
**Key Points:**
- No Authorization Required: This endpoint does not require an Authorization header.
- Parameters:
  - Only the id of the movie is required in the URL path.
- Response:
  - Returns detailed information about the movie, including title, release year, vote average, runtime, genres, summary, cast, total reviews, and user reviews.


### 4. Create Event
*POST* /api/v1/events

- Description: Creates a new event (viewing party) and invites users to it.
- Authorization: No Authorization header is needed. However, the api_key must be a valid key in the request body.
- Body Parameters:
  - name (required) - The name of the event.
  - start_time (required) - The start time of the event in ISO 8601 format (YYYY-MM-DDTHH:MM:SS).
  - end_time (required) - The end time of the event in ISO 8601 format.
  - movie_id (required) - The ID of the movie being watched.
  - movie_title (required) - The title of the movie.
  - api_key (required) - A valid API key belonging to the user creating the event.
  - invitees (optional) - An array of user IDs to invite to the event.

**Example Request:**
```
POST /api/v1/events
Content-Type: application/json
```
**Body:**
```
{
  "name": "Juliet's Bday Movie Bash!",
  "start_time": "2025-02-01 10:00:00",
  "end_time": "2025-02-01 14:30:00",
  "movie_id": 278,
  "movie_title": "The Shawshank Redemption",
  "api_key": "hruoVapmddwrLqDLvhpqKJXD",
  "invitees": [9, 10, 11]
}
```

**Example Response:**
```
{
  "data": {
    "id": "50",
    "type": "event",
    "attributes": {
      "id": 50,
      "name": "Juliet's Bday Movie Bash!",
      "start_time": "2025-02-01T10:00:00.000Z",
      "end_time": "2025-02-01T14:30:00.000Z",
      "movie_id": 278,
      "movie_title": "The Shawshank Redemption",
      "api_key": "hruoVapmddwrLqDLvhpqKJXD"
    },
    "relationships": {
      "users": {
        "data": [
          {
            "id": "9",
            "type": "user"
          },
          {
            "id": "10",
            "type": "user"
          },
          {
            "id": "11",
            "type": "user"
          }
        ]
      }
    }
  }
}
```
**Key Points:**

- **No Authorization Header**: This endpoint does not require an Authorization header. Instead, the api_key is passed as part of the body and must be validated.
- **Body Parameters**: All the necessary event details must be included in the body, and the invitees is an array of user IDs you wish to invite to the event.
- **Response**: If the api_key is valid, the response includes the event details, including the id, name, start_time, end_time, and movie details, along with the users who have been invited.


### 5.Update Event Invitees
*PATCH* /api/v1/events/:id

- Description: Updates the invitees of an event by adding or removing users.
- Parameters:
  - id (required) - The ID of the event to update.
- Body Parameters:
  - api_key (required) - The API key of the user performing the action.
  - invitees_user_id (required) - The ID of the user to invite or remove from the event.

**Example Request:**
```
PATCH /api/v1/events/1
Content-Type: application/json
```

**Body:**
```
{
  "api_key": "abcdefg123456",
  "invitees_user_id": "11"
}
```
**Example Response:**
```
{
  "data": {
    "id": "1",
    "type": "viewing_party",
    "attributes": {
      "name": "Juliet's Bday Movie Bash!",
      "start_time": "2025-02-01 10:00:00",
      "end_time": "2025-02-01 14:30:00",
      "movie_id": 278,
      "movie_title": "The Shawshank Redemption"
    },
    "relationships": {
      "users": {
        "data": [
          {
            "id": "11",
            "type": "user"
          },
          {
            "id": "7",
            "type": "user"
          },
          {
            "id": "5",
            "type": "user"
          }
        ]
      }
    }
  }
}
```
**Explanation:**

- Body Parameters:
  - api_key: Must be passed in the request body to identify the user making the change.
  - invitees_user_id: Specifies the user ID of the invitee being added.
- Response:
  - Returns the updated event with the current list of invited users (relationships -> users).

### 6. Get User Information
*GET* /api/v1/users/:id

- Description: Retrieves user information along with hosted and invited parties.
- Authentication: Requires the Authorization header with the user’s API key.
- Parameters:
    - id (required) - The ID of the user.

Example Request:
```
GET /api/v1/users/1234
Authorization: <USER_API_KEY>
```
Example Response:
```
{
  "data": {
    "id": "1234",
    "type": "user",
    "attributes": {
      "name": "Me",
      "username": "its_me",
      "api_key": "abcdefg123456",
      "hosted_parties": [
        {
          "id": 235,
          "name": "Juliet's Bday Movie Bash!",
          "start_time": "2025-02-01T10:00:00.000Z",
          "end_time": "2025-02-01T14:30:00.000Z",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "host_id": 1234
        }
      ],
      "viewing_parties_invited": [
        {
          "id": 236,
          "name": "Luigi's Party",
          "start_time": "2025-03-01T12:00:00.000Z",
          "end_time": "2025-03-01T14:00:00.000Z",
          "movie_id": 500,
          "movie_title": "Inception",
          "host_id": 2345
        }
      ]
    }
  }
}
```

