class StripeAccount < ApplicationRecord
  #has_many :campaigns

  validates :first_name,
  presence: true, length: { minimum: 1, maximum: 40 }
  validates :last_name,
  presence: true, length: { minimum: 1, maximum: 40 }

  validates :account_type,
  presence: true, inclusion: { in: %w(individual organization), message: "%{value} is not a valid account type"}

  validates :tos,
  inclusion: { in: [ true ], message: ": You must agree to the terms of service" }
end
