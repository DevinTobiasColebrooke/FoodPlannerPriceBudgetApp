RSpec.shared_examples "nutrient calculation with life stages" do |service_class|
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
          let(:service) { service_class.new(user_input, dri_lookup, energy_service) }

          it 'calculates nutrient requirements successfully' do
            result = service.calculate

            expect(result).to be_present
            expect(result).to be_a(Hash)
            expect(result).not_to be_empty
          end

          it 'returns valid numeric values' do
            result = service.calculate

            # Check that all numeric values in the result are valid
            result.each do |key, value|
              if value.is_a?(Hash)
                value.each do |sub_key, sub_value|
                  if sub_value.is_a?(Numeric)
                    expect(sub_value).to be >= 0
                  end
                end
              elsif value.is_a?(Numeric)
                expect(value).to be >= 0
              end
            end
          end
        end
      end
    end
  end
end

RSpec.shared_examples "fat component calculation" do |service_class|
  include LifeStageTestData

  let(:test_life_stages) do
    [
      :male_19_30_years,        # Adults
      :female_31_50_years,      # Adults
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
          let(:fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService.new(user_input, dri_lookup, energy_service) }
          let(:sat_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::SaturatedFatService.new(user_input, dri_lookup, energy_service) }
          let(:trans_fat_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::TransFattyAcidsService.new(user_input, dri_lookup, energy_service) }
          let(:pufa_service) { NutrientCalculator::CoreCalculation::EnergyMacronutrients::PolyunsaturatedFattyAcidsService.new(user_input, dri_lookup, energy_service) }
          let(:service) { service_class.new(user_input, dri_lookup, energy_service) }

          before do
            @total_fat = fat_service.calculate
            @sat_fat = sat_fat_service.calculate
            @trans_fat = trans_fat_service.calculate
            @pufa = pufa_service.calculate
          end

          it 'calculates fat component successfully' do
            result = service.calculate(@total_fat, @sat_fat, @trans_fat, @pufa)

            expect(result).to be_present
            expect(result).to be_a(Hash)
            expect(result).not_to be_empty
          end

          it 'returns valid numeric values' do
            result = service.calculate(@total_fat, @sat_fat, @trans_fat, @pufa)

            result.each do |key, value|
              if value.is_a?(Hash)
                value.each do |sub_key, sub_value|
                  if sub_value.is_a?(Numeric)
                    expect(sub_value).to be >= 0
                  end
                end
              elsif value.is_a?(Numeric)
                expect(value).to be >= 0
              end
            end
          end
        end
      end
    end
  end
end
