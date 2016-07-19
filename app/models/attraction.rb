class Attraction < ActiveRecord::Base
  require 'open-uri'

  validates :name, presence: true
  validates :link, uniqueness: true

  class << self
    def import_from_ta(ta_link)
      page = HTTParty.get(ta_link)

      parse_page = Nokogiri::HTML(page)
      parse_page.css('.property_title').map do |a|
        create(name: a.text,
               link: a.css('a').map { |link| 'https://pl.tripadvisor.com' + link['href'] }.first)
      end
      next_page = parse_page.css('.next').map { |a| a['href'] }.first
      import_from_ta('https://pl.tripadvisor.com' + next_page) if next_page
    end

    def import_visited(user_name)
      binding.pry
      Watir::Browser.new(:phantomjs)

      Selenium::WebDriver::PhantomJS.path = Phantomjs.path
      browser = Watir::Browser.new(:phantomjs)
      browser.goto('https://pl.tripadvisor.com/members/' + user_name)

      begin
        page = Nokogiri::HTML(browser.html)
        page.css('.cs-review-location').map do |a|
          Attraction.create(name: a.text,
                 link: a.css('a').map { |link| 'https://pl.tripadvisor.com' + link['href'] }.first,
                 visited: true)
        end

        browser.button(text: 'Następne').click
      end until page.css('#cs-paginate-next').first.attr('class') == 'disabled'
    end

    def to_csv
      attributes = %w{name latitude longitude link}

      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |attraction|
          csv << attributes.map{ |attr| attraction.send(attr) }
        end
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
