class DisputesController < ApplicationController
  before_action :authenticate_user!

  def create
    if dispute_params[:dispute_text].empty? || dispute_params[:dispute_id].empty?
      flash[:error] = "Please provide supporting information about this dispute"
      redirect_back(fallback_location: root_path) and return
    end

    begin
      # account for user
      account = Stripe::Account.retrieve(current_user.stripe_account)
      dispute = Stripe::Dispute.retrieve(dispute_params[:dispute_id])

      dispute.evidence.uncategorized_text = dispute_params[:dispute_text]
      dispute.evidence.uncategorized_file = dispute_params[:dispute_document]
      dispute.save

#back to page
      flash[:success] = "This dispute has been updated"
      redirect_back(fallback_location: root_path) and return

      #errors
        rescue Stripe::StripeError => e
          flash[:error] = e.message
          redirect_to dashboard_path
        rescue => e
          flash[:error] = e.message
          redirect_to dashboard_path
          
    end
  end

  private
    def dispute_params
      params.permit(:dispute_id, :dispute_text, :dispute_document)
    end
end
