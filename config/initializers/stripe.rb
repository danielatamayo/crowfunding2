Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'],
  :secret_key      => ENV['SECRET_KEY']
}

#testing key
Stripe.api_key = "sk_test_S0WCopLpy1JsaI9wVhaRdUeS"
