class Tripadvisor
  require 'selenium-webdriver'  

  def self.import(ta_link)
    page = HTTParty.get(ta_link)

    parse_page = Nokogiri::HTML(page)
    parse_page.css('.property_title').map do |a|
      attraction = Attraction.create(
                    name: a.text,
                    link: a.css('a').map { |link| 'https://pl.tripadvisor.com' + link['href'] }.first)
      attraction.download_location
    end
    next_page = parse_page.css('.next').map { |a| a['href'] }.first
    import_from_ta('https://pl.tripadvisor.com' + next_page) if next_page
  end

  def self.import_visited(user_name)
    Selenium::WebDriver::PhantomJS.path = Phantomjs.path
    browser = Watir::Browser.new(:phantomjs)
    browser.goto('https://pl.tripadvisor.com/members/' + user_name)

    loop do
      page = Nokogiri::HTML(browser.html)
      page.css('.cs-review-location').map do |a|
        attraction = Attraction.where(
                      link: a.css('a').map { 
                          |link| 'https://pl.tripadvisor.com' + link['href'] 
                        }).first_or_initialize
        attraction.name = a.text if attraction.name
        attraction.visited = true 
        attraction.save
      end

      browser.button(text: 'Następne').click
      break if page.css('#cs-paginate-next').first.attr('class') == 'disabled'
    end
  end
end