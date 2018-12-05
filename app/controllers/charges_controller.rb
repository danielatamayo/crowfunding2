class ChargesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :destroy]

  def create
#check for stripe
    unless charge_params[:stripeToken]
      flash[:error] = "No payment information submitted"
      redirect_back(fallback_location: root_path) and return
    end

    #check fundraiser
    unless charge_params[:campaign] && Campaign.exists?(charge_params[:campaign])
      flash[:error] = "The fundraiser you specified doesn't exist"
      redirect_back(fallback_location: root_path) and return
    end


    campaign = Campaign.find(params[:campaign])

#user id and fundraiser
    begin

      account_id = User.find(campaign.user_id).stripe_account


      amount = (100 * charge_params[:amount].tr('$', '').to_r).to_i

      charge = Stripe::Charge.create({
            source: charge_params[:stripeToken],
            amount: amount,
            currency: "usd",
            application_fee: amount/10, #maaybe charge 10% for it?
            destination: account_id,
            metadata: { "name" => charge_params[:name], "campaign" => campaign.id }
            }
      )


      local_charge = Charge.create(
        charge_id: charge.id,
        amount: amount,
        name: charge_params[:name],
        campaign_id: campaign.id
      )

      #amount raising
      campaign.raised = campaign.raised.to_i + amount
      campaign.save

      #Payment successful or not
      flash[:success] = "Thanks for your donation! Your transaction ID is #{charge.id}"
      redirect_to campaign_path(campaign)


          #stripe errors
          rescue Stripe::StripeError => e
            flash[:error] = e.message
            redirect_to campaign_path(campaign)

          rescue => e
            flash[:error] = e.message
            redirect_to campaign_path(campaign)
          end
  end

      def show
        begin
         
          @charge = Stripe::Charge.retrieve(id: params[:id], expand: ['application_fee', 'dispute'])


          check_destination(@charge)


          @campaign = Campaign.find(@charge.metadata.campaign)

            rescue Stripe::StripeError => e
              flash[:error] = e.message
              redirect_to dashboard_path

            rescue => e
              flash[:error] = e.message
              redirect_to dashboard_path
            end
      end

  def index
  end

  #refund charge
  def destroy
    begin
     
      charge = Stripe::Charge.retrieve(params[:id])
      check_destination(charge)
        charge.refund(reverse_transfer: true, refund_application_fee: true)

       
        local_charge = Charge.find_by charge_id: charge.id
        local_charge.amount_refunded = charge.amount
        local_charge.save

      #update amount raised after refund
      campaign = Campaign.find(local_charge.campaign_id)
      campaign.raised = campaign.raised.to_i - charge.amount
      campaign.save

      #successful or not
      flash[:success] = "The charge has been refunded"
      redirect_to dashboard_path

         
          rescue Stripe::StripeError => e
            flash.now[:error] = e.message
            redirect_to dashboard_path

         
          rescue => e
            flash.now[:error] = e.message
            redirect_to dashboard_path
          end
  end

  private
        def charge_params
          params.permit(:amount, :stripeToken, :name, :campaign, :authenticity_token)
        end

    #check for charge
    def check_destination(charge)

      unless charge.destination.eql?(current_user.stripe_account)
        flash[:error] = "You don't have access to this charge."
        redirect_to dashboard_path
      end
    end
end
