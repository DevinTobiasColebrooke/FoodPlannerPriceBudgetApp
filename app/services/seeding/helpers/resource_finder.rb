module Seeding
  module Helpers
    module ResourceFinder
      def self.find_or_create_resource(model_class, find_by_attrs, update_attrs = {})
        resource = model_class.find_or_initialize_by(find_by_attrs)

        # Attributes to set/update = find_by_attrs (to ensure they are set if new) + update_attrs
        # update_attrs take precedence if there are overlaps.
        all_attrs_to_set = find_by_attrs.merge(update_attrs)

        # Filter attributes to only those that exist on the model
        # Although assign_attributes does this, it's good for clarity and to avoid warnings.
        valid_attributes = all_attrs_to_set.select { |k, _| model_class.column_names.include?(k.to_s) }

        resource.assign_attributes(valid_attributes)

        if resource.new_record? || resource.changed?
          begin
            resource.save!
          rescue ActiveRecord::RecordInvalid => e
            puts "ERROR: Validation failed for #{model_class.name} with find_by_attrs: #{find_by_attrs}, update_attrs: #{update_attrs}. Errors: #{e.record.errors.full_messages.join(', ')}"
            puts "Attempted to save with attributes: #{valid_attributes.inspect}" # Debug attributes
          rescue => e
            puts "ERROR: Could not save #{model_class.name} with find_by_attrs: #{find_by_attrs}, update_attrs: #{update_attrs}. Error: #{e.message}"
            puts "Attempted to save with attributes: #{valid_attributes.inspect}" # Debug attributes
          end
        end
        resource
      end
    end
  end
end
