class Attraction < ActiveRecord::Base
  require 'open-uri'
  require 'selenium-webdriver'

  validates :name, presence: true
  validates :link, uniqueness: true

  scope :visited, -> { where(visited: true) }

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

    localization = Hash.new
    parse_page.css('.breadcrumb_link').each do |breadcrump|
      breadcrump_script = breadcrump.attr('onclick')
      local_type =  /(Continent|Country|Region|Province|Municipality|City|IslandGroup|Island)/.match(breadcrump_script).to_s
      next if local_type.empty?
      local_type = local_type.underscore.to_sym
      localization[local_type] = breadcrump.css('span').text
    end
    update(localization)

    return nil unless cont
    update(latitude: cont.attr('data-lat'), longitude: cont.attr('data-lng'))

  end
end
