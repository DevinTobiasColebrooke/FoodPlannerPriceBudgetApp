require 'rails_helper'

RSpec.describe NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService do
  include LifeStageTestData

  # Test representative life stages from each major category
  let(:test_life_stages) do
    [
      :infant_7_12_months,      # Infants
      :child_4_8_years,         # Children
      :female_14_18_years,      # Adolescents
      :male_19_30_years,        # Adults
      :female_51_70_years,      # Older Adults
      :pregnant_female_19_30_2nd_trimester,  # Pregnancy
      :lactating_female_19_30_0_6_months     # Lactation
    ]
  end

  describe '#calculate' do
    context 'with representative life stages' do
      test_life_stages.each do |life_stage_key|
        context "for #{life_stage_key}" do
          let(:user_input) { LifeStageTestData.create_user_input(life_stage_key) }
          let(:dri_lookup) { NutrientCalculator::Utility::DriLookupService.new(user_input) }
          let(:energy_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(user_input) }
          let(:fat_service) { described_class.new(user_input, dri_lookup, energy_service) }

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
      let(:fat_service) { described_class.new(user_input, dri_lookup, energy_service) }

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

  # Use shared examples for comprehensive testing
  it_behaves_like "nutrient calculation with life stages", described_class
end
