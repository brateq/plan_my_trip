class Attraction < ActiveRecord::Base
  def self.import_from_ta(ta_link)
    page = HTTParty.get(ta_link)

    parse_page = Nokogiri::HTML(page)
    parse_page.css('.property_title').map do |a|
      create(name: a.text, 
             link: a.css('a').map { |link| link['href'] }.first)
    end
  end

  def download_location
    parse_page = Nokogiri::HTML(open('https://tripadvisor.com' + link))
    cont = parse_page.css('.mapContainer').first
    return nil unless cont
    update(latitude: cont.attr('data-lat'), longitude: cont.attr('data-lng'))
  end
end
