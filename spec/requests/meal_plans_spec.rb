require 'rails_helper'

RSpec.describe "MealPlans", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/meal_plans/index"
      expect(response).to have_http_status(:success)
    end
  end

end
