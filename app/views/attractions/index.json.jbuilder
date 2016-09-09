json.array!(@attractions) do |attraction|
  json.extract! attraction, :id, :name, :type, :link, :latitude, :longitude
  json.url attraction_url(attraction, format: :json)
end
