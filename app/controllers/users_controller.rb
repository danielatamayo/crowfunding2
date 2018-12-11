class UsersController < ApplicationController

#resource registration - instead
=begin

def index 

end

  def show
    @user = User.find(params[:id])
    #@campaigns = @user.campaigns.paginate(page: params[:page])
      
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
  end


  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:organization, :email, :password,
                                   :password_confirmation)
    end

    #correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    #admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
=end
end