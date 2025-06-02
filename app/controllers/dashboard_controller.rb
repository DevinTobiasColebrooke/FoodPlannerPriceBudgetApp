class DashboardController < ApplicationController
  layout 'mobile'

  def show
    @current_user = Current.session.user
    # If @current_user is nil, it could be a guest or someone not logged in.
    # The view can then decide what to show.
    # For a guest who just completed onboarding, we might need another way
    # to identify them if a session wasn't started for them.
  end
end
