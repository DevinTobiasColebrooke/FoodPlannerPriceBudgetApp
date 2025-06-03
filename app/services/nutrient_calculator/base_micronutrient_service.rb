module NutrientCalculator
  class BaseMicronutrientService
    def initialize(user_input_dto, dri_lookup, nutrient)
      @user_input = user_input_dto
      @dri_lookup = dri_lookup
      @nutrient = nutrient
    end

    def calculate
      {
        nutrient_name: @nutrient.name,
        rda: get_rda,
        ai: get_ai,
        ul: get_ul,
        cdrr: get_cdrr,
        notes: generate_notes
      }
    end

    private

    def get_rda
      dri = @dri_lookup.get_dri(@nutrient.dri_identifier)
      return nil unless dri
      format_dri_value(dri)
    end

    def get_ai
      dri = @dri_lookup.get_dri(@nutrient.dri_identifier, dri_type: 'AI')
      return nil unless dri
      format_dri_value(dri)
    end

    def get_ul
      dri = @dri_lookup.get_dri(@nutrient.dri_identifier, dri_type: 'UL')
      return nil unless dri
      format_dri_value(dri)
    end

    def get_cdrr
      dri = @dri_lookup.get_dri(@nutrient.dri_identifier, dri_type: 'CDRR')
      return nil unless dri
      format_dri_value(dri)
    end

    def format_dri_value(dri)
      {
        value: dri[:value],
        unit: dri[:unit]
      }
    end

    def generate_notes
      notes = []
      notes << "Smoker adjustment applied" if @user_input.is_smoker?
      notes << "UL for supplemental forms only" if @nutrient.ul_supplemental_only?
      notes.join(", ")
    end
  end
end
