module NutrientCalculator
  module Utility
    class RdaCalculationService
      def self.calculate_rda(ear, sd_ear = nil)
        return nil unless ear

        if sd_ear
          # RDA = EAR + 2*SD_EAR
          (ear + (2 * sd_ear)).round
        else
          # RDA = EAR * 1.2 (default when SD not available)
          (ear * 1.2).round
        end
      end

      def self.calculate_ai(ear, sd_ear = nil)
        return nil unless ear

        if sd_ear
          # AI = EAR + 2*SD_EAR (same as RDA when SD available)
          calculate_rda(ear, sd_ear)
        else
          # AI = EAR * 1.2 (same as RDA when SD not available)
          calculate_rda(ear)
        end
      end
    end
  end
end
