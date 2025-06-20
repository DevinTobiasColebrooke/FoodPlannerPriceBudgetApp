module NutrientCalculator
  module Orchestration
    class NutrientCalculatorService
      def initialize(user_input_dto)
        @user_input = user_input_dto
        @dri_lookup = NutrientCalculator::Utility::DriLookupService.new(@user_input)
        @energy_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(@user_input)
        @bmi_service = NutrientCalculator::InputProcessing::BmiCalculationService.new(@user_input)
        @micronutrient_orchestrator = NutrientCalculator::Orchestration::MicronutrientOrchestratorService.new(@user_input, @dri_lookup)
      end

      def calculate
        energy_result = calculate_energy
        macronutrients_result = calculate_macronutrients(energy_result)

        {
          bmi: calculate_bmi,
          energy: energy_result,
          macronutrients: macronutrients_result,
          micronutrients: calculate_micronutrients
        }
      end

      private

      def calculate_bmi
        @bmi_service.calculate
      end

      def calculate_energy
        @energy_service.calculate
      end

      def calculate_macronutrients(energy_result)
        protein_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::ProteinService.new(@user_input, @dri_lookup, @energy_service)
        carb_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::CarbohydrateService.new(@user_input, @dri_lookup, @energy_service)
        fat_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService.new(@user_input, @dri_lookup, @energy_service)
        added_sugars_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::AddedSugarsService.new(@user_input, @dri_lookup, @energy_service)
        fiber_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::FiberService.new(@user_input, @dri_lookup, @energy_service)
        amino_acids_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::AminoAcidsService.new(@user_input, @dri_lookup, @energy_service)
        water_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::WaterService.new(@user_input, @dri_lookup, @energy_service)
        sat_fat_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::SaturatedFatService.new(@user_input, @dri_lookup, @energy_service)
        trans_fat_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::TransFattyAcidsService.new(@user_input, @dri_lookup, @energy_service)
        pufa_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::PolyunsaturatedFattyAcidsService.new(@user_input, @dri_lookup, @energy_service)

        total_fat = fat_service.calculate
        sat_fat = sat_fat_service.calculate
        trans_fat = trans_fat_service.calculate
        pufa = pufa_service.calculate

        mufa_service = NutrientCalculator::CoreCalculation::EnergyMacronutrients::MonounsaturatedFattyAcidsService.new(@user_input, @dri_lookup, @energy_service)

        {
          protein: protein_service.calculate,
          carbohydrates: carb_service.calculate,
          total_fat: total_fat,
          saturated_fat: sat_fat,
          trans_fat: trans_fat,
          polyunsaturated_fat: pufa,
          monounsaturated_fat: mufa_service.calculate(total_fat, sat_fat, trans_fat, pufa),
          added_sugars: added_sugars_service.calculate,
          fiber: fiber_service.calculate,
          amino_acids: amino_acids_service.calculate,
          water: water_service.calculate
        }
      end

      def calculate_micronutrients
        @micronutrient_orchestrator.calculate_all
      end
    end
  end
end
