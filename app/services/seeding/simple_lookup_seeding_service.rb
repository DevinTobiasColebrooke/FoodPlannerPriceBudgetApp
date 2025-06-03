module Seeding
  class SimpleLookupSeedingService
    def self.call
      new.call
    end

    def call
      seed_goals
      seed_allergies
      seed_kitchen_equipment
      seed_dietary_restrictions
      seed_legal_documents
    end

    private

    def seed_goals
      puts "Seeding Goals..."
      [
        { name: "Plan my meals for me", description: "Science based algorithmn plans meals for you, so you don't have to think about meals." },
        { name: "Meet Protein Goals", description: "A timer is set for maximum protein intake." },
        { name: "Weight Loss", description: "Focus on calorie deficit and nutrient-dense foods." },
        { name: "Eat Healthier", description: "Incorporate more whole foods and balanced meals." },
        { name: "Save Money", description: "Budget-friendly recipes and smart shopping." },
        { name: "Learn to Cook", description: "Beginner-friendly recipes and cooking tips." },
        { name: "Meal Prep Efficiency", description: "Recipes suitable for batch cooking and quick assembly." }
      ].each { |attrs| Helpers::ResourceFinder.find_or_create_resource(UserManagement::Goal, { name: attrs[:name] }, attrs.except(:name)) }
      puts "Goals seeded: #{UserManagement::Goal.count}"
    end

    def seed_allergies
      puts "Seeding Allergies..."
      [
        { name: "Dairy" }, { name: "Eggs" }, { name: "Tree Nuts" }, { name: "Peanuts" },
        { name: "Shellfish" }, { name: "Soy" }, { name: "Gluten" }, { name: "Fish" }, { name: "Sesame" }
      ].each { |attrs| Helpers::ResourceFinder.find_or_create_resource(UserManagement::Allergy, { name: attrs[:name] }, attrs.except(:name)) }
      puts "Allergies seeded: #{UserManagement::Allergy.count}"
    end

    def seed_kitchen_equipment
      puts "Seeding Kitchen Equipment..."
      [
        { name: "Instapot / Pressure Cooker" }, { name: "Blender" }, { name: "Immersion Blender" },
        { name: "Food Processor" }, { name: "Strainer / Colander" }, { name: "Juicer" },
        { name: "Oven" }, { name: "Microwave" }, { name: "Air Fryer" }
      ].each { |attrs| Helpers::ResourceFinder.find_or_create_resource(UserManagement::KitchenEquipment, { name: attrs[:name] }, attrs.except(:name)) }
      puts "Kitchen Equipment seeded: #{UserManagement::KitchenEquipment.count}"
    end

    def seed_dietary_restrictions
      puts "Seeding Dietary Restrictions..."
      [
        { name: "Vegan", description: "Excludes all animal products and by-products" },
        { name: "Vegetarian", description: "Excludes meat, fish, and poultry" },
        { name: "Low-Carb", description: "Restricts carbohydrate intake" }
      ].each { |attrs| Helpers::ResourceFinder.find_or_create_resource(UserManagement::DietaryRestriction, { name: attrs[:name] }, attrs.except(:name)) }
      puts "Dietary Restrictions seeded: #{UserManagement::DietaryRestriction.count}"
    end

    def seed_legal_documents
      puts "Seeding Legal Documents..."
      legal_docs = [
        {
          title: "Privacy Policy",
          content: File.read(Rails.root.join('app', 'views', 'legal_documents', 'privacy_policy.html.erb')),
          document_type: "privacy_policy",
          version: "1.0"
        },
        {
          title: "Terms of Service",
          content: File.read(Rails.root.join('app', 'views', 'legal_documents', 'terms_of_service.html.erb')),
          document_type: "terms_of_service",
          version: "1.0"
        }
      ]
      legal_docs.each do |attrs|
        doc = LegalDocument.find_or_initialize_by(document_type: attrs[:document_type], version: attrs[:version])
        doc.title = attrs[:title]
        doc.content = attrs[:content]
        doc.save!
      end
      puts "Legal Documents seeded: #{LegalDocument.count}"
    end
  end
end
