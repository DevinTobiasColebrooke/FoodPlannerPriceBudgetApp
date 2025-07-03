class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  def session=(session)
    super(session.is_a?(UserManagement::Session) ? session : nil)
  end
end
