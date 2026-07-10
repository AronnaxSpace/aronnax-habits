class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def aronnax
    @user = User.from_omniauth(request.env["omniauth.auth"])

    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "Aronnax") if is_navigational_format?
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_user_session_url, alert: e.record.errors.full_messages.join("\n")
  end

  def failure
    redirect_to new_user_session_path,
      alert: t("devise.omniauth_callbacks.failure", kind: "Aronnax", reason: failure_message)
  end
end
