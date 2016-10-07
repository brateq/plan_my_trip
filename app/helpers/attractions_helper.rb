module AttractionsHelper
  def google_attraction_photo(attraction)
    return unless attraction['photos']
    photo_id = attraction['photos'].first['photo_reference']
    image = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=#{photo_id}&key=" + ENV['gmaps_api_token']
    image_tag(image)
  end
end
