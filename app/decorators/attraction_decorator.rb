class AttractionDecorator < Draper::Decorator
  delegate_all

  def stats(type, name)
    statistics = Hash.new
    next_region_type = next_type(type)
    object.uniq.pluck(next_region_type).each do |current_region|
      attractions = object.where(next_region_type => current_region)
                          .where('stars >= ?', 4)
                          .where('reviews > ?', 2)
                          .count
      visited = object.where(next_region_type => current_region).visited.count
      percent = visited == 0 ? nil : h.number_to_percentage(visited.to_f / attractions.to_f * 100)

      location_stat = { current_region => { attractions: attractions,
                                          visited: visited,
                                          percent: percent } }

      statistics.merge! location_stat
    end

    statistics
  end

  def next_type(current_type)
    types = %w(continent country region province municipality city island_group island)
    index = types.index(current_type)
    types[index + 1]
  end
end
