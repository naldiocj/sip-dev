class ProcessStateTransition < ApplicationRecord
  self.table_name = "process_state_transitions"

  belongs_to :from_state, class_name: "ProcessState", foreign_key: :from_state_id
  belongs_to :to_state, class_name: "ProcessState", foreign_key: :to_state_id

  validates :action_code, presence: true
  validates :from_state_id, uniqueness: { scope: [ :to_state_id, :action_code ] }
  validates :active, inclusion: [ true, false ]

  scope :active, -> { where(active: true) }

  def self.allowed_transitions_from(state_code)
    from_state = ProcessState.find_by(code: state_code)
    return [] unless from_state

    active.where(from_state_id: from_state.id).includes(:to_state)
  end

  def self.can_transition?(from_state_code, to_state_code, action_code)
    transition = active.
      where(from_state_id: ProcessState.find_by(code: from_state_code)&.id).
      where(to_state_id: ProcessState.find_by(code: to_state_code)&.id).
      where(action_code: action_code).
      first

    transition.present?
  end
end
