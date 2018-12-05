class RegistrationsController < Devise::RegistrationsController

 
  protected

  def after_sign_up_path_for(resource)
    new_campaign_path
  end
=begin
   def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      
    else
      render 'new'
    end
  end


   private

    def user_params
      params.require(:user).permit(:organization, :email, :password,
                                   :password_confirmation)
    end
=end
end