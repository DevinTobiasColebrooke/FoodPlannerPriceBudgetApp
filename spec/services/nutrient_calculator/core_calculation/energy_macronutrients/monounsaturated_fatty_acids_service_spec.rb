require 'rails_helper'

RSpec.describe NutrientCalculator::CoreCalculation::EnergyMacronutrients::MonounsaturatedFattyAcidsService do
  include LifeStageTestData

  # Test representative life stages from each major category
  let(:test_life_stages) do
    [
      :male_19_30_years,        # Adults
      :female_31_50_years,      # Adults
      :pregnant_female_19_30_2nd_trimester,  # Pregnancy
      :lactating_female_19_30_0_6_months     # Lactation
    ]
  end

  describe 'MUFA calculation' do
    context 'with representative life stages' do
      test_life_stages.each do |life_stage_key|
        context "for #{life_stage_key}" do
          let(:user_input) { LifeStageTestData.create_user_input(life_stage_key) }
          let(:dri_lookup) { NutrientCalculator::Utility::DriLookupService.new(user_input) }
          let(:energy_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(user_input) }
          let(:fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService.new(user_input, dri_lookup, energy_service) }
          let(:sat_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::SaturatedFatService.new(user_input, dri_lookup, energy_service) }
          let(:trans_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::TransFattyAcidsService.new(user_input, dri_lookup, energy_service) }
          let(:pufa_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::PolyunsaturatedFattyAcidsService.new(user_input, dri_lookup, energy_service) }
          let(:mufa_service) { described_class.new(user_input, dri_lookup, energy_service) }

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
    end

    # Keep the original test for backward compatibility
    context 'with original test case' do
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
      let(:mufa_service) { described_class.new(user_input, dri_lookup, energy_service) }

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

  # Use shared examples for comprehensive testing
  it_behaves_like "fat component calculation", described_class
end
