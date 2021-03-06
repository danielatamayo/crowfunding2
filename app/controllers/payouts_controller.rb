class PayoutsController < ApplicationController
  before_action :authenticate_user!

  def show
    #payout from stripe account
    if params[:id]
      begin
        @stripe_account = Stripe::Account.retrieve(current_user.stripe_account)
        @payout = Stripe::Payout.retrieve(
              {
                id: params[:id]
              },
              { stripe_account: current_user.stripe_account }
        )

        @txns = Stripe::BalanceTransaction.list(
          {
            payout: params[:id],
            expand: ['data.source.source_transfer', 'data.source.charge.source_transfer'],
            limit: 100
          },
          { stripe_account: current_user.stripe_account }
        )



      rescue Stripe::StripeError => e
        flash[:error] = e.message
        redirect_to dashboard_path
      rescue => e
        flash[:error] = e.message
        redirect_to dashboard_path
      end
    else
      flash[:error] = "Sorry, this payout was not found"
      redirect_to dashboard_path
    end
  end
end
