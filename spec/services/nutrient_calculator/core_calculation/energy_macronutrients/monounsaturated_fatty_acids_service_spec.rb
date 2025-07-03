require 'rails_helper'

RSpec.describe NutrientCalculator::CoreCalculation::EnergyMacronutrients::MonounsaturatedFattyAcidsService do
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
  let(:sat_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::SaturatedFatService.new(user_input, dri_lookup, energy_service) }
  let(:trans_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::TransFattyAcidsService.new(user_input, dri_lookup, energy_service) }
  let(:pufa_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::PolyunsaturatedFattyAcidsService.new(user_input, dri_lookup, energy_service) }
  let(:mufa_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::MonounsaturatedFattyAcidsService.new(user_input, dri_lookup, energy_service) }

  describe 'MUFA calculation' do
    before do
      # Calculate all fat components needed for MUFA calculation
      @total_fat = fat_service.calculate
      @sat_fat = sat_fat_service.calculate
      @trans_fat = trans_fat_service.calculate
      @pufa = pufa_service.calculate
    end

    it 'successfully calculates MUFA when all fat components are provided' do
      mufa = mufa_service.calculate(@total_fat, @sat_fat, @trans_fat, @pufa)

      expect(mufa).to be_present
      expect(mufa).to be_a(Hash)
    end

    it 'calculates fat components correctly' do
      expect(@total_fat).to be_present
      expect(@sat_fat).to be_present
      expect(@trans_fat).to be_present
      expect(@pufa).to be_present
    end

    it 'returns valid fat component data structures' do
      expect(@total_fat).to be_a(Hash)
      expect(@sat_fat).to be_a(Hash)
      expect(@trans_fat).to be_a(Hash)
      expect(@pufa).to be_a(Hash)
    end
  end
end
