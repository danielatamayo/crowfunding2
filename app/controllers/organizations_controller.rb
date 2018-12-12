class OrganizationsController < ApplicationController
  
  def show
  	@organization = Organization.find(params[:id])
  end

  def new
  	@organization = Organization.new
  end

  def create
  	@organization = Organization.new(org_params)
  	if @organization.save
  		flash[:success] = "Successfully created organization!"
  		redirect_to @organization
  	else
  		render 'new'
  	end
  end

  private

  	def org_params
  		params.require(:organization).permit(:name, :email)
  	end

end
