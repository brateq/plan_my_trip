class GooglePlaces
  class << self
    def find_place(name)
      response = HTTParty.get(g_places_url,
                   query: { query: name,
                            key: ENV['gmaps_api_token'] })
      response['results']
    end

    def g_places_url
      'https://maps.googleapis.com/maps/api/place/textsearch/json'
    end
  end
end
