require_relative '../types/string_array_type'

module TypeRegistry
  extend ActiveSupport::Concern

  included do
    ActiveModel::Type.register(:string_array, StringArrayType.new)
    ActiveModel::Type.register(:hash, Hash)
  end
end
