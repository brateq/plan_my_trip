class Tripadvisor
  require 'selenium-webdriver'

  class << self
    def import(link)
      return import_category(link) unless category(link).nil?
      
      categories.each do |category_number, name|
        puts name
        category_link = link.gsub('Activities-', "Activities-c#{category_number}-")
        import_category(category_link)
      end
    end

    def import_category(link)
      page = HTTParty.get(link)

      parse_page = Nokogiri::HTML(page)
      parse_page.css('.attraction_element').map do |a|
        attraction = Attraction.create(location_prioperties(a))
        attraction.download_location
      end
      next_page = parse_page.css('.next').map { |a| a['href'] }.first
      import_category(ta_url + next_page) if next_page
    end

    def import_visited(user_name)
      Selenium::WebDriver::PhantomJS.path = Phantomjs.path
      browser = Watir::Browser.new(:phantomjs)
      browser.goto(ta_url + '/members/' + user_name)

      loop do
        page = Nokogiri::HTML(browser.html)
        page.css('.cs-review-location').map do |a|
          attraction = Attraction.where(
                        link: a.css('a').map {
                            |link| ta_url + link['href']
                          }).first_or_initialize
          attraction.name = a.text if attraction.name.nil?
          attraction.visited = true
          attraction.save
        end

        browser.button(text: 'Następne').click
        break if page.css('#cs-paginate-next').first.attr('class') == 'disabled'
      end
    end

    def location_prioperties(attraction_html)
      properties = Hash.new
      category = attraction_html.css('.p13n_reasoning_v2 a').first ? category(attraction_html.css('.p13n_reasoning_v2 a').first['href']) : '' 
      properties = {
        name: attraction_html.css('.property_title a').text,
        link: attraction_html.css('.property_title a').map { |link| ta_url + link['href'] }.first,
        stars: stars(attraction_html),
        reviews: reviews(attraction_html),
        category: category }
    end

    def stars(attraction_html)
      attraction_stars = attraction_html.css('.rate_no img').map { |i| i['alt'] }.first
      /^\S{1,3}/.match(attraction_stars).to_s.gsub(',', '.').to_f
    end

    def reviews(attraction_html)
      text = attraction_html.css('.more a').text.delete(' ')
       /(\d+)/.match(text).to_s.to_i
    end

    def category(link)
      category_number = /-c(\d{2})-/.match(link)
      return nil if category_number.nil?
      category_number = category_number.captures.first.to_i
      categories[category_number]
    end

    def categories
      {
        20 => 'Lokale czynne w nocy',
        47 => 'Zabytki i ciekawe miejsca',
        48 => 'Zoo i akwaria',
        49 => 'Muzea',
        52 => 'Parki rozrwki i parki wodne',
        55 => 'Rejsy i sporty wodne',
        56 => 'Gry i zabawy',
        57 => 'Parki i natura',
        61 => 'Wypoczynek na świeżym powietrzu'
      }
    end

    def ta_url
      'https://pl.tripadvisor.com'
    end
  end
end
