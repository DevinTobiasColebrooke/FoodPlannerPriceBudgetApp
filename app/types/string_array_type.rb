class StringArrayType < ActiveModel::Type::Value
  def initialize(**options)
    super
  end

  def type
    :string_array
  end

  def cast(value)
    return [] if value.nil?
    return value if value.is_a?(Array)
    return [] if value.empty?
    [value]
  end

  def serialize(value)
    value
  end

  def deserialize(value)
    cast(value)
  end
end
