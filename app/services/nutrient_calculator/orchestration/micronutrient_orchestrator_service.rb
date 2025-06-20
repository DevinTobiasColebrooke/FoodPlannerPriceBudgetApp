module NutrientCalculator
  module Orchestration
    class MicronutrientOrchestratorService
      MICRONUTRIENT_SERVICES = {
        # Vitamins
        vitamin_a: CoreCalculation::Micronutrients::VitaminAService,
        vitamin_c: CoreCalculation::Micronutrients::VitaminCService,
        vitamin_d: CoreCalculation::Micronutrients::VitaminDService,
        vitamin_e: CoreCalculation::Micronutrients::VitaminEService,
        vitamin_k: CoreCalculation::Micronutrients::VitaminKService,
        thiamin: CoreCalculation::Micronutrients::ThiaminService,
        riboflavin: CoreCalculation::Micronutrients::RiboflavinService,
        niacin: CoreCalculation::Micronutrients::NiacinService,
        vitamin_b6: CoreCalculation::Micronutrients::VitaminB6Service,
        vitamin_b12: CoreCalculation::Micronutrients::VitaminB12Service,
        folate: CoreCalculation::Micronutrients::FolateService,
        pantothenic_acid: CoreCalculation::Micronutrients::PantothenicAcidService,
        biotin: CoreCalculation::Micronutrients::BiotinService,
        choline: CoreCalculation::Micronutrients::CholineService,

        # Major Minerals
        calcium: CoreCalculation::Micronutrients::CalciumService,
        iron: CoreCalculation::Micronutrients::IronService,
        magnesium: CoreCalculation::Micronutrients::MagnesiumService,
        phosphorus: CoreCalculation::Micronutrients::PhosphorusService,
        potassium: CoreCalculation::Micronutrients::PotassiumService,
        sodium: CoreCalculation::Micronutrients::SodiumService,

        # Trace Minerals
        zinc: CoreCalculation::Micronutrients::ZincService,
        copper: CoreCalculation::Micronutrients::CopperService,
        manganese: CoreCalculation::Micronutrients::ManganeseService,
        selenium: CoreCalculation::Micronutrients::SeleniumService,
        chromium: CoreCalculation::Micronutrients::ChromiumService,
        molybdenum: CoreCalculation::Micronutrients::MolybdenumService,
        iodine: CoreCalculation::Micronutrients::IodineService,
        fluoride: CoreCalculation::Micronutrients::FluorideService,
        chloride: CoreCalculation::Micronutrients::ChlorideService,

        # Other Micronutrients
        carotenoids: CoreCalculation::Micronutrients::CarotenoidsService,
        vanadium: CoreCalculation::Micronutrients::VanadiumService,
        silicon: CoreCalculation::Micronutrients::SiliconService,
        nickel: CoreCalculation::Micronutrients::NickelService,
        boron: CoreCalculation::Micronutrients::BoronService,
        arsenic: CoreCalculation::Micronutrients::ArsenicService
      }.freeze

      def initialize(user_input_dto, dri_lookup)
        @user_input = user_input_dto
        @dri_lookup = dri_lookup
      end

      def calculate_all
        MICRONUTRIENT_SERVICES.each_with_object({}) do |(name, service_class), results|
          results[name] = service_class.new(@user_input, @dri_lookup).calculate
        end
      end
    end
  end
end
