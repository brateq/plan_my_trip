class AttractionDecorator < Draper::Decorator
  delegate_all

  def stats(type)
    statistics = {}
    next_region_type = next_type(type)
    object.uniq.pluck(next_region_type).each do |current_region|
      locations = object.where(next_region_type => current_region)

      attractions = locations.count
      visited = locations.visited.count
      percent = visited.zero? ? nil : h.number_to_percentage(visited.to_f / attractions.to_f * 100)

      location_stat = { current_region => { attractions: attractions,
                                            visited: visited,
                                            percent: percent } }

      statistics.merge! location_stat
    end

    statistics
  end

  def map_details
    hash = Gmaps4rails.build_markers(object) do |attraction, marker|
      next if attraction.latitude.nil?
      marker.json(id: attraction.id)
      marker.title attraction.name
      marker.infowindow "<a href='#{attraction.link}' target='_blank'>#{attraction.name}</a>
                         <p><a href='#{attraction.id}' data-method='delete' data-remote='true'>Destroy</a></p>"
      marker.lat attraction.latitude
      marker.lng attraction.longitude
    end
    hash.delete_if { |k, _v| k.empty? }
    hash.to_json
  end
end
