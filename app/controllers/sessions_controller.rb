class SessionsController < ApplicationController
  before_action :forbid_login_user , only: %i[new]

  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        flash[:success] = 'ログインに成功しました。'
        redirect_to user
      else
        message  = 'アカウントが有効化されていません。 '
        message += 'Eメールのアカウント有効化リンクをクリックしてください。'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:denger] = 'パスワードまたはEメールアドレスが間違っています。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
