class Attraction < ActiveRecord::Base
  require 'open-uri'
  require 'selenium-webdriver'

  validates :name, presence: true
  validates :link, uniqueness: true

  def self.to_csv
    attributes = %w(name latitude longitude link)

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |attraction|
        csv << attributes.map { |attr| attraction.send(attr) }
      end
    end
  end

  def download_location
    parse_page = Nokogiri::HTML(open(link))
    cont = parse_page.css('.mapContainer').first
    return nil unless cont
    update(latitude: cont.attr('data-lat'), longitude: cont.attr('data-lng'))
  end
end
