class Tripadvisor
  require 'selenium-webdriver'
  require 'open-uri'

  class << self
    def import(link)
      return import_category(link) unless category(link).nil?

      categories.each do |category_number, name|
        puts name
        category_link = link.gsub('Activities-', "Activities-c#{category_number}-")
        import_category(category_link)
      end
    end

    def import_continent(link)
      page = HTTParty.get(link)
      parse_page = Nokogiri::HTML(page)

      parse_page.css('.geo_name a').each do |location|
        link = ta_url + location['href']
        import(link)
      end
    end

    def import_from_city_list(link)
      page = HTTParty.get(link)
      parse_page = Nokogiri::HTML(page)

      parse_page.css('.geoList a').each do |location|
        link = ta_url + location['href']
        import(link)
      end

      next_page = parse_page.css('.sprite-pageNext').first['href']
      puts 'Current page: ' + link
      return if next_page.empty?

      import_from_city_list(ta_url + next_page) if next_page
    end

    def import_country(link)
      page = HTTParty.get(link)
      parse_page = Nokogiri::HTML(page)

      parse_page.css('#CHILD_GEO_FILTER .filter_list .filter a').each do |location|
        link = ta_url + location['href']
        import(link)
      end

      next_page = parse_page.css('.next').map { |a| a['href'] }.first
      import_continent(ta_url + next_page) if next_page
    end

    def import_category(link)
      page = HTTParty.get(link)
      parse_page = Nokogiri::HTML(page)

      ActiveRecord::Base.transaction do
        parse_page.css('.attraction_element').map do |a|
          attraction = Attraction.create(location_prioperties(a))
          attraction.download_location
        end
      end

      next_page = parse_page.css('.next').map { |a| a['href'] }.first
      import_category(ta_url + next_page) if next_page
    end

    def visited(user_name)
      browser = browser_init
      browser.goto(user_page_url(user_name))
      @attractions = []

      loop do
        page = Nokogiri::HTML(browser.html)

        page.css('.cs-review-location').map do |a|
          attraction = {}
          attraction[:link] = ta_url + a.css('a').first['href']
          attraction[:name] = a.text
          @attractions << attraction
        end

        browser.button(text: 'Następne').click
        return @attractions if last_page?(page)
      end
    end

    def location_prioperties(attraction_html)
      {
        name: attraction_html.css('.property_title a').text,
        link: attraction_html.css('.property_title a').map { |link| ta_url + link['href'] }.first,
        stars: stars(attraction_html),
        reviews: reviews(attraction_html),
        category: category(attraction_html.css('.p13n_reasoning_v2 a').first['href'])
      }
    end

    def stars(attraction_html)
      attraction_stars = attraction_html.css('.rate_no img').map { |i| i['alt'] }.first
      /^\S{1,3}/.match(attraction_stars).to_s.tr(',', '.').to_f
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

    def localization(link)
      parse_page = Nokogiri::HTML(open(link))

      localization = {}
      parse_page.css('.breadcrumb_link').each do |breadcrump|
        bc = breadcrump.attr('onclick')
        local_type = /(Continent|Country|Region|Province|Municipality|City|IslandGroup|Island)/.match(bc).to_s
        next if local_type.empty?
        local_type = local_type.underscore.to_sym
        localization[local_type] = breadcrump.css('span').text
      end

      cont = parse_page.css('.mapContainer').first

      coordinates = cont ? { latitude: cont.attr('data-lat'), longitude: cont.attr('data-lng') } : {}
      localization.merge(coordinates)
    end

    def browser_init
      Selenium::WebDriver::PhantomJS.path = Phantomjs.path
      Watir::Browser.new(:phantomjs)
    end

    def last_page?(page)
      page.css('#cs-paginate-next').first.attr('class') == 'disabled'
    end

    def user_page_url(user_name)
      ta_url + '/members/' + user_name
    end
  end
end
