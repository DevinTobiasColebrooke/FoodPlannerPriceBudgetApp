class LegalDocument < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :document_type, presence: true, inclusion: { in: %w[disclosure privacy_policy terms_of_service] }
  validates :version, presence: true

  scope :latest, -> { order(version: :desc) }
  scope :of_type, ->(type) { where(document_type: type) }

  def self.current_privacy_policy
    of_type('privacy_policy').latest.first
  end

  def self.current_terms_of_service
    of_type('terms_of_service').latest.first
  end

  def self.current_disclosure
    of_type('disclosure').latest.first
  end
end
