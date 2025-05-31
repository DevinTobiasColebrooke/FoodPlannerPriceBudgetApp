require_relative 'string_array_type'
require_relative 'hash_type'

module TypeRegistry
  extend ActiveSupport::Concern

  included do
    ActiveModel::Type.register(:string_array, StringArrayType)
    ActiveModel::Type.register(:hash, HashType)
  end
end
