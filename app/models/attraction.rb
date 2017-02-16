class Attraction < ActiveRecord::Base
  has_many :statuses
  has_many :users, through: :statuses

  validates :name, presence: true
  validates :link, uniqueness: true

  scope :visited, -> { where(visited: true) }
  scope :not_visited, -> { where(visited: false) }
  scope :want_to_visit, -> { where(status: ['must see', 'later', nil]) }
  scope :must_see, -> { where(status: 'must see') }

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
    return false if latitude
    update(Tripadvisor.localization(link))
  end

  def self.import_visited(ta_user_name, user)
    Tripadvisor.visited(ta_user_name).each do |location|
      attraction = where(link: location[:link]).first_or_initialize
      location.merge!(Tripadvisor.localization(location[:link])) unless attraction.continent
      attraction.update(location)

      attraction.statuses.create(visited: true, user: user)
    end
  end

  def self.next_type(current_type)
    types = %w(continent country region province municipality city island_group island)
    index = types.index(current_type)
    types[index + 1]
  end
end
