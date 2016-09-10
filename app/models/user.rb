class User < ApplicationRecord
  has_many :statuses
  has_and_belongs_to_many :attractions, through: :statuses 

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
