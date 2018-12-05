class WebhooksController < ApplicationController
  protect_from_forgery except: :stripe

  def stripe
    #webhooks
    endpoint_secret = ENV['ENDPOINT_SECRET'].to_s

        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )

      case event.type

      # fees
      when 'charge.dispute.created'
        #dispute
        dispute = event.data.object
        charge = Stripe::Charge.retrieve(dispute.charge)

        #platform ID Stripe
        platform_account = Stripe::Account.retrieve
        reverse_transfer(charge)

        #account debit for transfer
        debit = Stripe::Transfer.create(
              {
                amount: dispute.balance_transactions.first.fee,
                currency: "usd",
                destination: platform_account.id,
                description: "Dispute fee for #{charge.id}"
              },
              { stripe_account: charge.destination }
        )
      when 'charge.dispute.funds_reinstated'
        dispute = event.data.object
        charge = Stripe::Charge.retrieve(dispute.charge)

        #transfer to account
        transfer = Stripe::Transfer.create(
          amount: dispute.balance_transactions.second.net,
          currency: "usd",
          destination: charge.destination
        )
        payment = Stripe::Charge.retrieve(
          {
            id: transfer.destination_payment
          },
          {
            stripe_account: transfer.destination
          }
        )
        payment.description = "Chargeback reversal for #{charge.id}"
        payment.save

      end

        #errors!
        rescue JSON::ParserError, Stripe::SignatureVerificationError, Stripe::StripeError => e
          head :bad_request
        rescue => e
          head :bad_request
        end

    head :ok
  end

      private
        def reverse_transfer(charge)
          transfer = Stripe::Transfer.retrieve(charge.transfer)
          transfer.reversals.create
        end
end
