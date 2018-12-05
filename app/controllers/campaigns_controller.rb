class CampaignsController < ApplicationController
  before_action :authenticate_user!, except: [:home, :show]
  include CampaignsHelper

  def home
    #fundraisers
    @campaigns = Campaign.where(active: true).order(created_at: :desc).page params[:page]
  end

  def new
    #if not account
    unless current_user.stripe_account
      redirect_to new_stripe_account_path and return
    end


    #new fundraiser
    @campaign = Campaign.new
  end

  def create
    #create fundraiser
    @campaign = current_user.campaigns.new(campaign_params)

        #show fundraiser
        if @campaign.save
          flash[:notice] = "Your fundraiser has been created!"
          redirect_to @campaign
        else
          handle_error(@campaign.errors.full_messages, 'new')
        end
  end

  def show
    #find fundraiser
    @campaign = Campaign.find(params[:id])

    #charges
    @charges = Charge.where(campaign_id: @campaign.id, amount_refunded: nil).order(created_at: :desc)
  end

  def dashboard
    #fundraiser for signed user
    @campaigns = current_user.campaigns.order(created_at: :desc)

    #redirect if user doesn't have Stripe
    unless current_user.stripe_account
      flash[:success] = "Create an account to get started."
      redirect_to new_stripe_account_path and return
    end

    #STRIPEEEE
    begin
      @stripe_account = Stripe::Account.retrieve(current_user.stripe_account)

      #charges
      @payments = Stripe::Charge.list(
        {
              limit: 100,
              expand: ['data.source_transfer.source_transaction.dispute', 'data.application_fee'],
              source: {object: 'all'}
        },
        { stripe_account: current_user.stripe_account }
      )

      #payouts
      @payouts = Stripe::Payout.list(
        {
          limit: 100,
          expand: ['data.destination']
        },
        { stripe_account: current_user.stripe_account }
      )

      #balance 
      @balance = Stripe::Balance.retrieve(stripe_account: current_user.stripe_account)
      @balance_available = @balance.available.first.amount + @balance.pending.first.amount

 
      transactions = Stripe::BalanceTransaction.all(
        {
          limit: 100,
          available_on: {gte: Time.now.to_i}
        },
        { stripe_account: current_user.stripe_account }
      )


      balances = Hash.new
      transactions.auto_paging_each do |txn|
        if balances.key?(txn.available_on)
          balances[txn.available_on] += txn.net
        else
          balances[txn.available_on] = txn.net
        end
      end

      #sorting
      @transactions = balances.sort_by {|date,net| date}

      #check for linked external account
      @debit_card = @stripe_account.external_accounts.find { |c| c.object == "card"}
         @instant_amt = @balance_available*0.97
      @instant_fee = @balance_available*0.03

    
    rescue Stripe::StripeError => e
      flash[:error] = e.message
      redirect_to root_path


    rescue => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

        #see fundraiser
        def edit

          @campaign = Campaign.find(params[:id])
        end

        def update

          @campaign = Campaign.find(params[:id])


          if @campaign.update_attributes(campaign_params)
            flash[:notice] = "Your campaign has been updated!"
            redirect_to @campaign
          else
            handle_error(@campaign.errors.full_messages, 'edit')
          end
        end

#delete fundraiser
  def destroy

    campaign = Campaign.find(params[:id])

    if campaign.update_attributes(active: false)
      flash[:notice] = "Your campaign has been deleted."
      redirect_to dashboard_path
    else
      flash[:error] = "We weren't able to delete this campaign."
      redirect_to dashboard_path
    end
  end

        private
          def campaign_params
            params.require(:campaign).permit(:title, :description, :goal, :subscription, :image)
          end

 
end
