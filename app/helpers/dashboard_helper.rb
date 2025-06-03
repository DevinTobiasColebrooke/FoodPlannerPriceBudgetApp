module DashboardHelper
  def bmi_status_color(category)
    case category
    when 'Underweight'
      'text-fp-accent-yellow'
    when 'Normal weight'
      'text-fp-primary-green'
    when 'Overweight'
      'text-fp-accent-orange'
    when 'Obese'
      'text-fp-error'
    else
      'text-fp-neutral-text-light'
    end
  end
end
