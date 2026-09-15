class WorkflowTransition < ApplicationRecord
  include Scopeable
  belongs_to :process, class_name: "Sip::Process", foreign_key: :process_id
  belongs_to :actor, class_name: "User", foreign_key: :actor_id, optional: true

  validates :from_state, presence: true
  validates :to_state, presence: true
  validates :action, presence: true
end
