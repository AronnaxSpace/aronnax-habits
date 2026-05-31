class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_authenticated

  def index
  end

  private

  def redirect_if_authenticated
    redirect_to authenticated_root_path if user_signed_in?
  end
end
