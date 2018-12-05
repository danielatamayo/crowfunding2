class Campaign < ApplicationRecord
  belongs_to :user
  #belongs_to :stripeaccount

  validates :title,
  presence: true, length: { minimum: 5, maximum: 100 }

  validates :goal, 
  presence: true, numericality: { greater_than: 20, less_than: 1000000 }

  validates :description,
  presence: true, length: { minimum: 10, maximum: 5000 }



#  def self.search(search)  
 #  where("lower(stripeaccounts.first_name) LIKE :search OR lower(campaigns.title) LIKE :search", search: "%#{search.downcase}%").uniq   
#end
end
