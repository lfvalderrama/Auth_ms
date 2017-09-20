class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate_request!, only:[:show, :update,:get_user]



  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show
    if @current_user.id == params[:id].to_i
      get_user
    else
      renderResponse("Forbidden",403,"current user has no access")
    end
  end

  # POST /users
  def create
      @user = User.new(user_params)
    if @user.save
      UserNotifierMailer.send_signup_email(@user).deliver
      head 201
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @current_user.id == params[:id].to_i
      if user_params[:email] == @current_user.email || !user_params[:email]
        if @user.update(user_params)
          head 204
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      else
        renderResponse("Not acceptable",406,"Email can't be updated")
      end
    else
      renderResponse("Forbidden",403,"current user has no access")
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user && user.authenticate(params[:password])
      if user.confirmed_at?
        auth_token = JsonWebToken.encode({user_id: user.id})
        render json: {auth_token: auth_token}, status: :ok
      else
        renderResponse("Unauthenticated",401,"Email not verified")
      end
    else
      renderResponse("Unauthenticated",401,"Invalid username / password")
    end
  end

  def get_user
    render json: {id: @current_user.id,
                  firstName: @current_user.firstName,
                  lastName: @current_user.lastName,
                  email: @current_user.email,
                  money: @current_user.money}
  end

  def search_user
    user=User.find_by(id: params[:id])
    if user
      renderResponse("Success",200,"The user exists")
    else
      renderResponse("Not found",404,"The user does not exists")
    end
  end


  def confirm
    token = params[:token].to_s
    user = User.find_by(confirmation_token: token)
    if user.present? && user.confirmation_token_valid?
      user.mark_as_confirmed!
      UserNotifierMailer.send_confirm_email(user).deliver
      render json: "Email succesfully confirmed", status: :ok
    else
      renderResponse("Not found",404,"Invalid token")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:firstName, :lastName, :money, :email, :token, :password, :password_confirmation)
    end
end
