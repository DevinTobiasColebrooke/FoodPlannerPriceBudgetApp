class NutrientCalculatorService
  def initialize(user_input_dto)
    @user_input = user_input_dto
    @dri_lookup = NutrientCalculator::DriLookupService.new(user_input_dto)
    @energy_service = NutrientCalculator::EnergyRequirementService.new(user_input_dto, @dri_lookup)
  end

  def calculate
    {
      bmi: calculate_bmi,
      energy: calculate_energy,
      macronutrients: calculate_macronutrients,
      micronutrients: calculate_micronutrients
    }
  end

  private

  def calculate_bmi
    bmi_service = NutrientCalculator::BmiCalculationService.new(@user_input)
    bmi_service.calculate
  end

  def calculate_energy
    @energy_service.calculate
  end

  def calculate_macronutrients
    {
      protein: calculate_protein,
      carbohydrates: calculate_carbohydrates,
      fat: calculate_fat
    }
  end

  def calculate_protein
    protein_service = NutrientCalculator::ProteinService.new(@user_input, @dri_lookup, @energy_service)
    protein_service.calculate
  end

  def calculate_carbohydrates
    carb_service = NutrientCalculator::CarbohydrateService.new(@user_input, @dri_lookup, @energy_service)
    carb_service.calculate
  end

  def calculate_fat
    fat_service = NutrientCalculator::FatService.new(@user_input, @dri_lookup, @energy_service)
    fat_service.calculate
  end

  def calculate_micronutrients
    {
      vitamin_a: calculate_vitamin_a
      # Add other micronutrients as needed
    }
  end

  def calculate_vitamin_a
    vitamin_a_service = NutrientCalculator::VitaminAService.new(@user_input, @dri_lookup)
    vitamin_a_service.calculate
  end
end
