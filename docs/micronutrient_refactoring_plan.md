# Micronutrient Calculation Refactoring Plan

## Overview
Refactor the micronutrient calculation system to improve code organization, maintainability, and scalability by introducing a dedicated orchestrator service.

## Current State
- All micronutrient calculations are currently handled directly in `NutrientCalculatorService`
- Only Vitamin A is implemented, with 34 other micronutrients pending
- Each micronutrient has its own service class in `app/services/nutrient_calculator/core_calculation/micronutrients/`

## File Structure
- Base service: `app/services/nutrient_calculator/core_calculation/micronutrients/base_micronutrient_service.rb`
- Individual services: `app/services/nutrient_calculator/core_calculation/micronutrients/*_service.rb`
- New orchestrator: `app/services/nutrient_calculator/orchestration/micronutrient_orchestrator_service.rb`
- Main calculator: `app/services/nutrient_calculator/orchestration/nutrient_calculator_service.rb`

## Micronutrient Services List

### Vitamins
1. Vitamin A - `VitaminAService`
2. Vitamin C - `VitaminCService`
3. Vitamin D - `VitaminDService`
4. Vitamin E - `VitaminEService`
5. Vitamin K - `VitaminKService`
6. Thiamin (B1) - `ThiaminService`
7. Riboflavin (B2) - `RiboflavinService`
8. Niacin (B3) - `NiacinService`
9. Vitamin B6 - `VitaminB6Service`
10. Vitamin B12 - `VitaminB12Service`
11. Folate - `FolateService`
12. Pantothenic Acid (B5) - `PantothenicAcidService`
13. Biotin (B7) - `BiotinService`
14. Choline - `CholineService`

### Major Minerals
15. Calcium - `CalciumService`
16. Iron - `IronService`
17. Magnesium - `MagnesiumService`
18. Phosphorus - `PhosphorusService`
19. Potassium - `PotassiumService`
20. Sodium - `SodiumService`

### Trace Minerals
21. Zinc - `ZincService`
22. Copper - `CopperService`
23. Manganese - `ManganeseService`
24. Selenium - `SeleniumService`
25. Chromium - `ChromiumService`
26. Molybdenum - `MolybdenumService`
27. Iodine - `IodineService`
28. Fluoride - `FluorideService`
29. Chloride - `ChlorideService`

### Other Micronutrients
30. Carotenoids - `CarotenoidsService`
31. Vanadium - `VanadiumService`
32. Silicon - `SiliconService`
33. Nickel - `NickelService`
34. Boron - `BoronService`
35. Arsenic - `ArsenicService`

## Implementation Steps

### 1. Create MicronutrientOrchestratorService
- Create new file: `app/services/nutrient_calculator/orchestration/micronutrient_orchestrator_service.rb`
- Implement base structure with initialization and main calculation method
- Add individual calculation methods for each micronutrient

### 2. Update NutrientCalculatorService
- Modify `calculate_micronutrients` method to use the new orchestrator
- Remove individual micronutrient calculation methods
- Update tests to reflect new structure

### 3. Implementation Order
1. Create orchestrator service with Vitamin A implementation
2. Add remaining micronutrient calculation methods in batches:
   - Batch 1: Core Vitamins (A, C, D, E, K, B-complex)
   - Batch 2: Major Minerals (Calcium, Iron, Magnesium, Phosphorus, Potassium)
   - Batch 3: Trace Minerals (Zinc, Copper, Manganese, Selenium)
   - Batch 4: Other Micronutrients (remaining elements)

## Code Structure

### New Orchestrator Service
```ruby
module NutrientCalculator
  module Orchestration
    class MicronutrientOrchestratorService
      def initialize(user_input_dto, dri_lookup)
        @user_input = user_input_dto
        @dri_lookup = dri_lookup
      end

      def calculate_all
        {
          vitamin_a: calculate_vitamin_a,
          # ... other micronutrients
        }
      end

      private

      def calculate_vitamin_a
        VitaminAService.new(@user_input, @dri_lookup).calculate
      end

      # ... other calculation methods
    end
  end
end
```

### Updated NutrientCalculatorService
```ruby
def calculate_micronutrients
  micronutrient_orchestrator = MicronutrientOrchestratorService.new(@user_input, @dri_lookup)
  micronutrient_orchestrator.calculate_all
end
```

## Benefits
1. Improved code organization
2. Better separation of concerns
3. Easier maintenance and updates
4. Simplified main calculator service
5. More scalable architecture

## Timeline
1. Day 1: Create orchestrator and implement Vitamin A
2. Day 2: Implement Batch 1 (Core Vitamins)
3. Day 3: Implement Batch 2 (Major Minerals)
4. Day 4: Implement Batch 3 (Trace Minerals)
5. Day 5: Implement Batch 4 (Other Micronutrients)
6. Day 6: Testing and bug fixes

## Success Criteria
- All 35 micronutrients are properly calculated
- No regression in existing functionality
- Code coverage maintained or improved
- Documentation updated 