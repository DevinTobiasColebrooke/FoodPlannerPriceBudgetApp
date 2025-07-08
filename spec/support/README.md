# Test Support Documentation

## Life Stage Test Data

This directory contains support files for testing nutrient calculations across multiple life stages in a scalable and maintainable way.

### Overview

Instead of creating individual test cases for each of the 81+ life stages defined in `db/data_sources/life_stages.csv`, we use a representative sampling approach that covers all major life stage categories.

### Files

- `life_stage_test_data.rb` - Contains predefined test data for representative life stages
- `shared_examples/nutrient_calculation_examples.rb` - Shared RSpec examples for nutrient calculations

### Life Stage Categories

The test data covers these major categories:

1. **Infants** (0-12 months)
   - 0-6 months
   - 7-12 months

2. **Children** (1-8 years)
   - 12-23 months (toddlers)
   - 1-3 years
   - 4-8 years

3. **Adolescents** (9-18 years)
   - 9-13 years (male/female)
   - 14-18 years (male/female)

4. **Adults** (19-50 years)
   - 19-30 years (male/female)
   - 31-50 years (male/female)

5. **Older Adults** (51+ years)
   - 51-70 years (male/female)
   - 71+ years (male/female)

6. **Special Conditions**
   - Pregnancy (1st, 2nd, 3rd trimester)
   - Lactation (0-6 months, 7-12 months)

### Usage

#### Basic Usage

```ruby
require 'rails_helper'

RSpec.describe MyNutrientService do
  include LifeStageTestData

  let(:test_life_stages) do
    [
      :infant_7_12_months,
      :child_4_8_years,
      :male_19_30_years,
      :female_51_70_years
    ]
  end

  describe '#calculate' do
    test_life_stages.each do |life_stage_key|
      context "for #{life_stage_key}" do
        let(:user_input) { LifeStageTestData.create_user_input(life_stage_key) }
        let(:service) { described_class.new(user_input) }

        it 'calculates successfully' do
          result = service.calculate
          expect(result).to be_present
        end
      end
    end
  end
end
```

#### Using Shared Examples

```ruby
RSpec.describe MyNutrientService do
  # Use shared examples for comprehensive testing
  it_behaves_like "nutrient calculation with life stages", described_class
end
```

#### Custom Life Stage Selection

```ruby
# Test specific categories
adult_life_stages = LifeStageTestData.life_stages_by_category[:adults]
pregnancy_life_stages = LifeStageTestData.life_stages_by_category[:pregnancy]

# Test all life stages
all_life_stages = LifeStageTestData.life_stage_keys
```

### Benefits

1. **Scalability**: Test 20+ representative life stages instead of 81+ individual cases
2. **Maintainability**: Centralized test data that's easy to update
3. **Coverage**: Ensures all major life stage categories are tested
4. **Reusability**: Shared examples can be used across multiple services
5. **Performance**: Faster test execution while maintaining good coverage

### Adding New Life Stages

To add a new life stage to the test data:

1. Add the life stage data to `LIFE_STAGE_CATEGORIES` in `life_stage_test_data.rb`
2. Update the `life_stages_by_category` method if needed
3. Add the new life stage to relevant test files

### Best Practices

1. **Choose Representative Cases**: Select life stages that represent the extremes and typical cases within each category
2. **Test Edge Cases**: Include pregnancy, lactation, and older adult scenarios
3. **Maintain Consistency**: Use the same test data across related services
4. **Document Changes**: Update this README when adding new life stages or changing the approach

### Example Test Output

When running tests, you'll see output like:

```
NutrientCalculator::CoreCalculation::EnergyMacronutrients::FatService
  #calculate
    with representative life stages
      for infant_7_12_months
        calculates fat requirements with AMDR data
      for child_4_8_years
        calculates fat requirements with AMDR data
      for female_14_18_years
        calculates fat requirements with AMDR data
      for male_19_30_years
        calculates fat requirements with AMDR data
      for female_51_70_years
        calculates fat requirements with AMDR data
      for pregnant_female_19_30_2nd_trimester
        calculates fat requirements with AMDR data
      for lactating_female_19_30_0_6_months
        calculates fat requirements with AMDR data
```

This approach provides comprehensive testing coverage while remaining maintainable and performant. 