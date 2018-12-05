class BankAccountsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    #redirect if no stripe account
    unless current_user.stripe_account
      redirect_to new_stripe_account_path and return
    end

    begin
      #account for this user
      @account = Stripe::Account.retrieve(current_user.stripe_account)
    
    #stripe errors
    rescue Stripe::StripeError => e
      handle_error(e.message, 'new')
    
    #errors
    rescue => e
      handle_error(e.message, 'new')
    end 
  end

  def create
    #redirect if no stripe account
    unless params[:stripeToken] && current_user.stripe_account
      redirect_to new_bank_account_path and return
    end

    begin
      
      account = Stripe::Account.retrieve(current_user.stripe_account)

      #bank account
      account.external_account = params[:stripeToken]
      account.save
      
      #sent to dashboard
      flash[:success] = "Your bank account has been added!"
      redirect_to dashboard_path
    
    #error mssgs
    rescue Stripe::StripeError => e
      handle_error(e.message, 'new')

   
    rescue => e
      handle_error(e.message, 'new')
    end
  end
end
