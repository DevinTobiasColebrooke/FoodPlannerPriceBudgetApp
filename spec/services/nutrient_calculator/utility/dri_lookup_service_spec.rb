require 'rails_helper'

RSpec.describe NutrientCalculator::Utility::DriLookupService do
  let(:user_input) do
    OpenStruct.new(
      age_in_months: 324,  # 27 years old
      sex: 'male',
      weight_kg: 113.0,
      height_cm: 193.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    )
  end

  let(:dri_lookup) { NutrientCalculator::Utility::DriLookupService.new(user_input) }
  let(:energy_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(user_input) }
  let(:fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService.new(user_input, dri_lookup, energy_service) }

  describe 'AMDR lookup for FAT' do
    it 'successfully retrieves AMDR percentages' do
      amdr_result = dri_lookup.get_amdr_percentage('FAT')

      expect(amdr_result).to be_present
      expect(amdr_result).to have_key(:min_percent)
      expect(amdr_result).to have_key(:max_percent)
      expect(amdr_result[:min_percent]).to be_a(Numeric)
      expect(amdr_result[:max_percent]).to be_a(Numeric)
      expect(amdr_result[:min_percent]).to be < amdr_result[:max_percent]
    end
  end

  describe 'FatService with AMDR' do
    it 'calculates fat requirements with AMDR data' do
      fat_result = fat_service.calculate

      expect(fat_result).to be_present
      expect(fat_result).to have_key(:amdr)
      expect(fat_result[:amdr]).to have_key(:percent_min)
      expect(fat_result[:amdr]).to have_key(:percent_max)
      expect(fat_result[:amdr][:percent_min]).to be_a(Numeric)
      expect(fat_result[:amdr][:percent_max]).to be_a(Numeric)
      expect(fat_result[:amdr][:percent_min]).to be < fat_result[:amdr][:percent_max]
    end
  end
end
