class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R )
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    movies = []
    begin
    
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      if Tmdb::Movie.find(string) == nil
        return movies
      end
      Tmdb::Movie.find(string).each do |movie|
        movie_info = {}
        movie_info["id"] = movie.id
        movie_info["title"] = movie.title
        movie_info["release_date"] = movie.release_date
        Tmdb::Movie.releases(movie.id)["countries"].each do |x|
          movie_info["rating"] = ""
          if x["iso_3166_1"] == "US" && x["certification"] != ""
            movie_info["rating"] = x["certification"]
            break
          end
        end
        movies += [movie_info]
      end
      
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
    movies
    
  end
  
  def self.create_from_tmdb(id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    new = {}
    new["title"] = Tmdb::Movie.detail(id)["title"]
    new["release_date"] = Tmdb::Movie.detail(id)["release_date"]
    new["rating"] = ""
    if Tmdb::Movie.releases(id)["countries"] != nil then
    Tmdb::Movie.releases(id)["countries"].each do |x|
      if x["iso_3166_1"] == "US"
        new["rating"] = x["certification"]
        if x["certification"] != ""
              break
        end
      end
    end
    end
    Movie.create(new).save()
    
  end

end