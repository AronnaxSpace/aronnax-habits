class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def aronnax
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Aronnax") if is_navigational_format?
    else
      session["devise.aronnax_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to new_user_session_path,
      alert: t("devise.omniauth_callbacks.failure", kind: "Aronnax", reason: failure_message)
  end
end
