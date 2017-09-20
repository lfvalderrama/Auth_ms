class UserNotifierMailer < ApplicationMailer
  default :from => 'no_reply@MagicWallet.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Confirm email' )
  end

  def send_confirm_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Wellcome to MagicWallet' )
  end
end
