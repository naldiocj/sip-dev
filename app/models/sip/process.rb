module Sip
  class Process < ApplicationRecord
    self.table_name = "processes"

    PRIORITIES = %w[normal alta urgente].freeze
    STATES = ProcessState.pluck(:code)

    belongs_to :process_type
    belongs_to :process_nature
    belongs_to :process_origin
    belongs_to :process_priority
    belongs_to :confidentiality_level
    belongs_to :process_state
    belongs_to :created_by, class_name: "User"
    belongs_to :updated_by, class_name: "User"
  belongs_to :organizacao, class_name: "Organization", optional: true
  belongs_to :responsavel, class_name: "User", optional: true

    has_many :process_parties, dependent: :restrict_with_error
    has_many :parties, through: :process_parties, source: :person
    has_many :party_types, through: :process_parties

    has_many :process_locations, dependent: :restrict_with_error
    has_many :process_assignments, dependent: :restrict_with_error
    has_many :process_movements, dependent: :destroy
    has_many :process_transitions, dependent: :destroy
    has_many :process_deadlines, dependent: :restrict_with_error
    has_many :process_legal_classifications, dependent: :restrict_with_error
    has_many :legal_references, through: :process_legal_classifications
    has_many :process_closures, dependent: :restrict_with_error
    has_many :process_reopenings, dependent: :restrict_with_error
    has_many :process_audit_events, dependent: :destroy

    validates :numero, presence: true
    validates :ano, presence: true
    validates :titulo, presence: true
    validates :data_entrada, presence: true
    validates :numero, uniqueness: { scope: :ano }

    before_create :set_uuid

    delegate :code, to: :process_state, prefix: :state

    def current_location
      process_locations.order(:started_at).last
    end

    def current_assignment
      process_assignments.where("ended_at IS NULL OR ended_at > ?", Time.current).order(:started_at).last
    end

    def active_deadline
      process_deadlines.where(status: "EM_CURSO").order(:due_at).first
    end

    def days_until_deadline
      return nil unless active_deadline
      (active_deadline.due_at - Time.current).to_i/86400
    end

    def is_overdue?
      active_deadline&.due_at&.past? == true
    end

    private

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end
  end
end
