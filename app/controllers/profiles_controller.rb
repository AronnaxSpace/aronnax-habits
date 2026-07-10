class ProfilesController < ApplicationController
  helper_method :profile

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if profile.update(profile_params)
        format.html { redirect_to profile_path, notice: t(".success"), status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    current_user.destroy
    sign_out(current_user)
    redirect_to root_path, notice: t(".success"), status: :see_other
  end

  private

  def profile = @profile ||= current_user.profile
  def profile_params = params.expect(profile: [ :nickname, :language, :week_starts_on ])
end
