class PagesController < ApplicationController


def show
end


def search  

	if params[:search].blank?  
    redirect_to(root_path, alert: "Empty field!") and return  
  else  
    @parameter = params[:search].downcase  
    @results = User.all.where("lower(email) LIKE :search", search: "%#{@parameter}%")  
  
  #@results = Fundraiser.joins(:user).search(params[:search]).order("user.organization DESC")
  end 


end
  
end