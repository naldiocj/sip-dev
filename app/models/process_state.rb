class ProcessState < ApplicationRecord
  self.table_name = "process_states"

  has_many :outgoing_transitions, class_name: "ProcessStateTransition", foreign_key: :from_state_id, dependent: :restrict_with_error
  has_many :incoming_transitions, class_name: "ProcessStateTransition", foreign_key: :to_state_id, dependent: :restrict_with_error

  has_many :processes, foreign_key: :process_state_id, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :terminal, inclusion: [ true, false ]
  validates :active, inclusion: [ true, false ]

  scope :active, -> { where(active: true) }
  scope :terminal, -> { where(terminal: true) }
  scope :non_terminal, -> { where(terminal: false) }
end
