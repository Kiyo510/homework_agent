# frozen_string_literal: true

module SessionsHelper
  # 渡されたユーザーでログインをする
  def log_in(user)
    session[:user_id] = user.id
  end

  # セッションを永続化する
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user&.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 受けとったユーザーデータがcurrent_userと一致するならtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # ユーザーがログインしているかどうか調べる
  def logged_in?
    !current_user.nil?
  end

  def forbid_login_user
    redirect_to items_path unless current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # ユーザーのセッションを削除してログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
