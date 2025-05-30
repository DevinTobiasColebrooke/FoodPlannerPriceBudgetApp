class CreateLegalDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_documents do |t|
      t.string :title
      t.text :content
      t.string :document_type
      t.string :version

      t.timestamps
    end
  end
end
