class Status < ApplicationRecord
  belongs_to :user
  belongs_to :attraction

  validates :user, uniqueness: { scope: :attraction }
end
