class StripeAccountsController < ApplicationController
  before_action :authenticate_user!

  def new
    @account = StripeAccount.new
  end

  def create
    @account = StripeAccount.new(account_params)

    if @account.save
      begin


        #Sripe Account
        if params[:full_account]
          stripe_account = Stripe::Account.create(
            type: 'custom',
            legal_entity: {
              first_name: account_params[:first_name].capitalize,
              last_name: account_params[:last_name].capitalize,
              type: account_params[:account_type],
              dob: {
                day: account_params[:dob_day],
                month: account_params[:dob_month],
                year: account_params[:dob_year]
              },
              address: {
                line1: account_params[:address_line1],
                city: account_params[:address_city],
                state: account_params[:address_state],
                postal_code: account_params[:address_postal]
              },
              ssn_last_4: account_params[:ssn_last_4]
            },
            tos_acceptance: {
              date: Time.now.to_i,
              ip: request.remote_ip
            }
          )
        end
   

      #id
      @account.acct_id = stripe_account.id
      @account.save
      current_user.stripe_account = stripe_account.id



      if current_user.save
        flash[:success] = "Your account has been created!
          Add a bank account to receive transfers."
        redirect_to new_bank_account_path
      else
        handle_error("Sorry, couldn't create account", 'new')
      end


      rescue Stripe::StripeError => e
        handle_error(e.message, 'new')
      rescue => e
        handle_error(e.message, 'new')
      end
    else
      @full_account = true if params[:full_account]
      handle_error(@account.errors.full_messages)
    end
  end

  def edit
    #stripe account
    unless params[:id] && params[:id].eql?(current_user.stripe_account)
      flash[:error] = "No Stripe account specified"
      redirect_to dashboard_path and return
    end

    @stripe_account = Stripe::Account.retrieve(params[:id])
    @account = StripeAccount.find_by(acct_id: params[:id])

    if @stripe_account.verification.fields_needed.empty?
      flash[:success] = "Your information is all up to date."
      redirect_to dashboard_path and return
    end
  end

  
  def full
    @account = StripeAccount.new
    @full_account = true
  end

 #rescue Stripe::StripeError => e
  #          handle_error(e.message, 'edit')
   #       rescue => e
    #        handle_error(e.message, 'edit')
     #     end
     
  def update
    #existing stripe account
    unless current_user.stripe_account
      redirect_to new_stripe_account_path and return
    end

    begin
      
      @stripe_account = Stripe::Account.retrieve(current_user.stripe_account)
      @account = StripeAccount.new(account_params)


      #check for empty values
      account_params.each do |key, value|
        if value.empty?
          flash.now[:alert] = "Please complete empty fields"
          render 'edit' and return
        end
      end


            @stripe_account.verification.fields_needed.each do |field|

              #update fields
              case field
              when 'legal_entity.address.city'
                @stripe_account.legal_entity.address.city = account_params[:address_city]
              when 'legal_entity.address.line1'
                @stripe_account.legal_entity.address.line1 = account_params[:address_line1]
              when 'legal_entity.address.postal_code'
                @stripe_account.legal_entity.address.postal_code = account_params[:address_postal]
              when 'legal_entity.address.state'
                @stripe_account.legal_entity.address.state = account_params[:address_state]
              when 'legal_entity.dob.day'
                @stripe_account.legal_entity.dob.day = account_params[:dob_day]
              when 'legal_entity.dob.month'
                @stripe_account.legal_entity.dob.month = account_params[:dob_month]
              when 'legal_entity.dob.year'
                @stripe_account.legal_entity.dob.year = account_params[:dob_year]
              when 'legal_entity.first_name'
                @stripe_account.legal_entity.first_name = account_params[:first_name]
              when 'legal_entity.last_name'
                @stripe_account.legal_entity.last_name = account_params[:last_name]
              when 'legal_entity.ssn_last_4'
                @stripe_account.legal_entity.ssn_last_4 = account_params[:ssn_last_4]
              when 'legal_entity.type'
                @stripe_account.legal_entity.type = account_params[:type]
              when 'legal_entity.personal_id_number'
                @stripe_account.legal_entity.personal_id_number = account_params[:personal_id_number]
              when 'legal_entity.verification.document'
                @stripe_account.legal_entity.verification.document = account_params[:verification_document]
              when 'legal_entity.business_name'
                @stripe_account.legal_entity.business_name = account_params[:business_name]
              when 'legal_entity.business_tax_id'
                @stripe_account.legal_entity.business_tax_id = account_params[:business_tax_id]
              end
            end

      @stripe_account.save
      flash[:success] = "Thanks! Your account has been updated."
      redirect_to dashboard_path and return


          rescue Stripe::StripeError => e
            handle_error(e.message, 'edit')
          rescue => e
            handle_error(e.message, 'edit')
          end
  end

  private
    def account_params
      params.require(:stripe_account).permit(
        :first_name, :last_name, :account_type, :dob_month, :dob_day, :dob_year, :tos,
        :ssn_last_4, :address_line1, :address_city, :address_state, :address_postal, :business_name,
        :business_tax_id, :full_account, :personal_id_number, :verification_document
      )
    end
end