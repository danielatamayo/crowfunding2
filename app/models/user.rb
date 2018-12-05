class User < ApplicationRecord
  has_many :campaigns
  
  #include default modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
