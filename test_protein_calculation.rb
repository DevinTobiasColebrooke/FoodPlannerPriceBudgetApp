#!/usr/bin/env ruby

# Simple test to verify protein calculation with new requirements
require 'ostruct'
require_relative 'config/environment'

# Test case 1: Adult male, 70 kg
puts "=== Testing Updated Protein Calculation ==="

user_input1 = OpenStruct.new(
  age_in_months: 360,  # 30 years old
  sex: 'male',
  weight_kg: 70.0,
  height_cm: 175.0,
  physical_activity_level: 'moderately_active',
  is_pregnant: false,
  is_lactating: false
)

puts "User: 30-year-old male, 70 kg"
puts "Expected RDA: 70 kg × 0.80 g/kg = 56 g"

dri_lookup1 = NutrientCalculator::Utility::DriLookupService.new(user_input1)
energy_service1 = NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(user_input1)
protein_service1 = NutrientCalculator::CoreCalculation::EnergyMacronutrients::ProteinService.new(user_input1, dri_lookup1, energy_service1)

result1 = protein_service1.calculate

puts "\n=== Results ==="
puts "RDA per kg: #{result1[:rda_g_per_kg]} g/kg"
puts "RDA total: #{result1[:rda_g_total]} g"
puts "AI total: #{result1[:ai_g_total]} g"
puts "AMDR: #{result1[:amdr][:percent_min]}% - #{result1[:amdr][:percent_max]}% (#{result1[:amdr][:grams][:min_grams]} - #{result1[:amdr][:grams][:max_grams]} g)"

expected_rda1 = 70.0 * 0.80
puts "\n=== Verification ==="
puts "Expected RDA: #{expected_rda1} g"
puts "Calculated RDA: #{result1[:rda_g_total]} g"
puts "Match: #{result1[:rda_g_total] == expected_rda1.round ? '✓' : '✗'}"

# Test case 2: 27-year-old male, 113 kg, 193 cm tall
puts "\n\n=== Testing 27-year-old male, 113 kg, 193 cm ==="
user_input2 = OpenStruct.new(
  age_in_months: 27 * 12,  # 27 years old
  sex: 'male',
  weight_kg: 113.0,
  height_cm: 193.0,
  physical_activity_level: 'moderately_active',
  is_pregnant: false,
  is_lactating: false
)

puts "User: 27-year-old male, 113 kg, 193 cm"
puts "Expected RDA: 113 kg × 0.80 g/kg = #{113.0 * 0.80} g"

dri_lookup2 = NutrientCalculator::Utility::DriLookupService.new(user_input2)
energy_service2 = NutrientCalculator::CoreCalculation::EnergyMacronutrients::EnergyRequirementService.new(user_input2)
protein_service2 = NutrientCalculator::CoreCalculation::EnergyMacronutrients::ProteinService.new(user_input2, dri_lookup2, energy_service2)

result2 = protein_service2.calculate

puts "\n=== Results ==="
puts "RDA per kg: #{result2[:rda_g_per_kg]} g/kg"
puts "RDA total: #{result2[:rda_g_total]} g"
puts "AI total: #{result2[:ai_g_total]} g"
puts "AMDR: #{result2[:amdr][:percent_min]}% - #{result2[:amdr][:percent_max]}% (#{result2[:amdr][:grams][:min_grams]} - #{result2[:amdr][:grams][:max_grams]} g)"

expected_rda2 = 113.0 * 0.80
puts "\n=== Verification ==="
puts "Expected RDA: #{expected_rda2} g"
puts "Calculated RDA: #{result2[:rda_g_total]} g"
puts "Match: #{result2[:rda_g_total] == expected_rda2.round ? '✓' : '✗'}"

puts "\n=== Test Complete ==="
