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

  private

  def profile = @profile ||= current_user.profile
  def profile_params = params.expect(profile: [ :nickname, :language ])
end
