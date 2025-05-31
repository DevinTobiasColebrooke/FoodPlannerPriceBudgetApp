class HashType < ActiveModel::Type::Value
  def initialize(**options)
    super
  end

  def type
    :hash
  end

  def cast(value)
    return {} if value.nil?
    return value if value.is_a?(Hash)
    value.to_h
  end

  def serialize(value)
    value
  end

  def deserialize(value)
    cast(value)
  end
end
