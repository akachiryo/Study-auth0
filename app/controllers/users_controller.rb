class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  #新規登録ページ
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.auth0_id = "仮のpassword"
    if @user.save!
      redirect_to login_path
    else
      redirect_to signup_path
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end
end
