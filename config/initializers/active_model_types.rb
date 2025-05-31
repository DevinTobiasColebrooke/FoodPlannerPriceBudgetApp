# Load custom type definitions
require_relative '../../app/types/string_array_type'
require_relative '../../app/types/hash_type'

# Register custom types
ActiveModel::Type.register(:string_array, StringArrayType)
ActiveModel::Type.register(:hash, HashType)
