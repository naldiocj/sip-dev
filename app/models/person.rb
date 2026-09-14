class Person < ApplicationRecord
  self.table_name = "people"

  has_many :parental_relations_as_child, class_name: "PersonParentalRelation", foreign_key: :person_id, dependent: :destroy
  has_many :parents, through: :parental_relations_as_child, source: :parent
  has_many :parental_relations_as_parent, class_name: "PersonParentalRelation", foreign_key: :parent_id, dependent: :destroy
  has_many :children, through: :parental_relations_as_parent, source: :child

  has_many :identity_documents, class_name: "PersonIdentityDocument", dependent: :destroy
  has_many :addresses, through: :person_addresses, dependent: :destroy
  has_many :person_addresses, dependent: :destroy
  has_many :contacts, class_name: "PersonContact", dependent: :destroy

  has_many :process_parties, dependent: :destroy
  has_many :processes, through: :process_parties

  validates :nome_completo, presence: true
  validates :nome_proprio, presence: true
  validates :apelido, presence: true

  scope :active, -> { where.not(data_nascimento: nil..Date.today) }

  def full_name
    [ nome_proprio, nome_meio, apelido ].compact.join(" ")
  end

  def primary_identity_document
    identity_documents.find_by(is_primary: true) || identity_documents.first
  end

  def primary_address
    person_addresses.find_by(is_primary: true)&.address || addresses.first
  end

  def primary_contact
    contacts.find_by(is_primary: true) || contacts.first
  end
end
