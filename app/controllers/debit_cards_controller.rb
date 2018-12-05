class DebitCardsController < ApplicationController
  before_action :authenticate_user!

  def new
    
  end

  def create
    #if no stripe account
        unless params[:stripeToken] && current_user.stripe_account
          redirect_to debit_cards_create_path and return
        end

    begin
      #account of current user
      account = Stripe::Account.retrieve(current_user.stripe_account)

  
      account.external_accounts.create(external_account: params[:stripeToken])
      account.save
      flash[:success] = "Your debit card has been added!"
      redirect_to dashboard_path

    
        rescue Stripe::StripeError => e
          handle_error(e.message, 'new')
        rescue => e
          handle_error(e.message, 'new')
    end
  end

  def destroy
  end

  def transfer
    begin
      
      account = Stripe::Account.retrieve(current_user.stripe_account)

      
      payout = Stripe::Payout.create(
        {
          amount: params[:amount],
          currency: "usd",
          method: "instant",
          destination: params[:destination]
        },
        { stripe_account: account.id }
      )
      Stripe::Charge.create(
              amount: params[:fee],
              currency: "usd",
              source: account.id,
              description: "Instant payout fee for #{payout.id}"
      )
      #back to dashboar
      flash[:success] = "Your payout has been made!"
      redirect_to dashboard_path


          rescue Stripe::StripeError => e
            flash[:error] = e.message
            redirect_to dashboard_path
          rescue => e
            flash[:error] = e.message
            redirect_to dashboard_path
    end
  end
end
