class AttractionDecorator < Draper::Decorator
  delegate_all

  def continents_stats
    continents = Hash.new
    object.uniq.pluck(:continent).each do |continent|
      attractions = object.where(continent: continent).count
      visited = object.where(continent: continent).visited.count
      percent = visited == 0 ? nil : h.number_to_percentage(visited.to_f / attractions.to_f * 100)

      continent_stat =  { continent => { attractions: attractions,
                                         visited: visited,
                                         percent: percent } }

      continents.merge! continent_stat
    end

    continents
  end
end
