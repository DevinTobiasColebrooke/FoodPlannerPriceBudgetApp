class Onboarding::AvatarsController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @avatars = list_avatars
  end

  def create
    @avatars = list_avatars # Ensure @avatars is available if create fails and re-renders new
    if update_onboarding_profile(avatar_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def list_avatars
    avatar_base_path = "920999-avatar/svg"
    # Path for Dir.glob to find files in the assets directory
    # Rails.root.join combines the application's root path with the relative path to the assets.
    directory_path = Rails.root.join("app", "assets", "images", avatar_base_path)

    # Check if the directory exists to prevent errors
    return [] unless Dir.exist?(directory_path)

    Dir.glob(File.join(directory_path, "*.svg")).map do |filepath|
      filename = File.basename(filepath, ".svg")
      {
        id: filename, # e.g., "001-man"
        name: filename.gsub(/^[0-9]+-/, '').gsub("-", " ").capitalize, # e.g., "Man"
        path: File.join(avatar_base_path, File.basename(filepath)) # e.g., "920999-avatar/svg/001-man.svg"
      }
    end.sort_by { |avatar| avatar[:id] } # Optional: sort avatars by ID
  rescue StandardError => e
    Rails.logger.error "Failed to list avatars: #{e.message}"
    [] # Return an empty array in case of an error
  end

  def avatar_params
    params.require(:onboarding_profile).permit(
      :avatar_url,
      :selected_avatar_identifier
    )
  end
end
