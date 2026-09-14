# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_14_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.string "password_hash"
    t.string "verification_token"
    t.datetime "verified_at"
    t.datetime "locked_at"
    t.integer "failed_login_count", default: 0
    t.datetime "last_login_at"
    t.string "session_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["login"], name: "index_accounts_on_login", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["verification_token"], name: "index_accounts_on_verification_token"
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "pais"
    t.string "provincia"
    t.string "municpio"
    t.string "comuna"
    t.string "bairro"
    t.string "rua"
    t.string "numero_porta"
    t.string "andar"
    t.string "apartamento"
    t.text "referencia"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "capabilities", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "confidentiality_levels", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_confidentiality_levels_on_code", unique: true
  end

  create_table "deadline_suspensions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_deadline_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.text "reason"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_deadline_suspensions_on_created_by_id"
    t.index ["process_deadline_id"], name: "index_deadline_suspensions_on_process_deadline_id"
  end

  create_table "diligence_types", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "diligences", force: :cascade do |t|
    t.integer "process_id"
    t.string "diligencia_type"
    t.string "descricao"
    t.string "estado"
    t.integer "responsavel_id"
    t.date "data_prevista"
    t.datetime "data_real"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "diligencia_type_id"
    t.index ["diligencia_type_id"], name: "index_diligences_on_diligencia_type_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "process_id"
    t.integer "document_type_id"
    t.string "title"
    t.text "description"
    t.string "status"
    t.integer "uploader_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evidences", force: :cascade do |t|
    t.integer "process_id"
    t.string "evidence_type"
    t.string "descricao"
    t.integer "collector_id"
    t.datetime "collected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legal_references", force: :cascade do |t|
    t.string "code"
    t.string "diploma"
    t.string "artigo"
    t.string "numero"
    t.string "alinea"
    t.text "descricao"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_legal_references_on_code"
  end

  create_table "mandates", force: :cascade do |t|
    t.integer "process_id"
    t.string "mandate_type"
    t.integer "emissor_id"
    t.string "destino"
    t.text "descricao"
    t.string "estado"
    t.date "data_emissao"
    t.date "data_prazo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "parent_id"
    t.string "level"
    t.text "description"
    t.integer "created_by"
    t.integer "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
  end

  create_table "party_types", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_party_types_on_code", unique: true
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome_completo", null: false
    t.string "nome_proprio"
    t.string "nome_meio"
    t.string "apelido"
    t.date "data_nascimento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome_completo"], name: "index_people_on_nome_completo"
  end

  create_table "person_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.uuid "address_id", null: false
    t.string "address_type", null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_person_addresses_on_address_id"
    t.index ["person_id", "address_id"], name: "index_person_addresses_on_person_id_and_address_id", unique: true
    t.index ["person_id"], name: "index_person_addresses_on_person_id"
  end

  create_table "person_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "contact_type", null: false
    t.string "contact_value", null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "contact_type", "contact_value"], name: "idx_on_person_id_contact_type_contact_value_51f923af8b", unique: true
    t.index ["person_id"], name: "index_person_contacts_on_person_id"
  end

  create_table "person_identity_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "document_type", null: false
    t.string "document_number", null: false
    t.date "issued_at"
    t.date "expires_at"
    t.string "issuing_authority"
    t.boolean "is_primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "document_number"], name: "idx_on_person_id_document_number_e9f378da2a", unique: true
    t.index ["person_id"], name: "index_person_identity_documents_on_person_id"
  end

  create_table "person_parental_relations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.uuid "parent_id", null: false
    t.string "relation_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_person_parental_relations_on_parent_id"
    t.index ["person_id", "parent_id"], name: "index_person_parental_relations_on_person_id_and_parent_id", unique: true
    t.index ["person_id"], name: "index_person_parental_relations_on_person_id"
  end

  create_table "process_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.bigint "assigned_to_user_id", null: false
    t.bigint "assigned_to_organization_id", null: false
    t.string "assignment_type", null: false
    t.bigint "assigned_by_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_process_assignments_on_assigned_by_id"
    t.index ["assigned_to_organization_id"], name: "index_process_assignments_on_assigned_to_organization_id"
    t.index ["assigned_to_user_id"], name: "index_process_assignments_on_assigned_to_user_id"
    t.index ["process_id", "started_at"], name: "index_process_assignments_on_process_id_and_started_at"
    t.index ["process_id"], name: "index_process_assignments_on_process_id"
  end

  create_table "process_audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "entity_type"
    t.bigint "entity_id"
    t.jsonb "before_data"
    t.jsonb "after_data"
    t.inet "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "created_at"], name: "index_process_audit_events_on_actor_id_and_created_at"
    t.index ["actor_id"], name: "index_process_audit_events_on_actor_id"
    t.index ["process_id", "created_at"], name: "index_process_audit_events_on_process_id_and_created_at"
    t.index ["process_id"], name: "index_process_audit_events_on_process_id"
  end

  create_table "process_closures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.string "closure_type", null: false
    t.datetime "closed_at", null: false
    t.bigint "closed_by_id", null: false
    t.text "reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_process_closures_on_closed_by_id"
    t.index ["process_id"], name: "index_process_closures_on_process_id"
  end

  create_table "process_deadlines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.string "deadline_type", null: false
    t.datetime "start_at", null: false
    t.datetime "due_at", null: false
    t.datetime "completed_at"
    t.string "status", default: "EM_CURSO", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_process_deadlines_on_created_by_id"
    t.index ["process_id", "deadline_type"], name: "index_process_deadlines_on_process_id_and_deadline_type"
    t.index ["process_id"], name: "index_process_deadlines_on_process_id"
  end

  create_table "process_legal_classifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.bigint "legal_reference_id", null: false
    t.boolean "primary", default: false, null: false
    t.text "observacao"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_process_legal_classifications_on_created_by_id"
    t.index ["legal_reference_id"], name: "index_process_legal_classifications_on_legal_reference_id"
    t.index ["process_id"], name: "index_process_legal_classifications_on_process_id"
  end

  create_table "process_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.bigint "organization_id", null: false
    t.bigint "user_id"
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.text "reason"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_process_locations_on_created_by_id"
    t.index ["organization_id"], name: "index_process_locations_on_organization_id"
    t.index ["process_id", "started_at"], name: "index_process_locations_on_process_id_and_started_at"
    t.index ["process_id"], name: "index_process_locations_on_process_id"
    t.index ["user_id"], name: "index_process_locations_on_user_id"
  end

  create_table "process_movements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.string "movement_type", null: false
    t.bigint "from_organization_id"
    t.bigint "to_organization_id"
    t.bigint "from_user_id"
    t.bigint "to_user_id"
    t.bigint "performed_by_id", null: false
    t.text "reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_organization_id"], name: "index_process_movements_on_from_organization_id"
    t.index ["from_user_id"], name: "index_process_movements_on_from_user_id"
    t.index ["performed_by_id"], name: "index_process_movements_on_performed_by_id"
    t.index ["process_id", "created_at"], name: "index_process_movements_on_process_id_and_created_at"
    t.index ["process_id"], name: "index_process_movements_on_process_id"
    t.index ["to_organization_id"], name: "index_process_movements_on_to_organization_id"
    t.index ["to_user_id"], name: "index_process_movements_on_to_user_id"
  end

  create_table "process_natures", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_process_natures_on_code", unique: true
  end

  create_table "process_origins", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_process_origins_on_code", unique: true
  end

  create_table "process_parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.uuid "person_id", null: false
    t.bigint "party_type_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.string "status", default: "ATIVO", null: false
    t.text "observacao"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_process_parties_on_created_by_id"
    t.index ["party_type_id"], name: "index_process_parties_on_party_type_id"
    t.index ["person_id"], name: "index_process_parties_on_person_id"
    t.index ["process_id", "person_id", "party_type_id"], name: "idx_on_process_id_person_id_party_type_id_28b95c4122", unique: true
    t.index ["process_id"], name: "index_process_parties_on_process_id"
  end

  create_table "process_priorities", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_process_priorities_on_code", unique: true
  end

  create_table "process_reopenings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.datetime "reopened_at", null: false
    t.bigint "reopened_by_id", null: false
    t.string "legal_basis"
    t.text "reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_id"], name: "index_process_reopenings_on_process_id"
    t.index ["reopened_by_id"], name: "index_process_reopenings_on_reopened_by_id"
  end

  create_table "process_state_transitions", force: :cascade do |t|
    t.integer "from_state_id", null: false
    t.integer "to_state_id", null: false
    t.string "action_code", null: false
    t.string "description"
    t.boolean "requires_reason", default: false, null: false
    t.boolean "requires_destination", default: false, null: false
    t.boolean "requires_responsible", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_state_id", "to_state_id", "action_code"], name: "idx_on_from_state_id_to_state_id_action_code_ef8e5ce678", unique: true
    t.index ["from_state_id"], name: "index_process_state_transitions_on_from_state_id"
    t.index ["to_state_id"], name: "index_process_state_transitions_on_to_state_id"
  end

  create_table "process_states", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "terminal", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_process_states_on_code", unique: true
  end

  create_table "process_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "process_id", null: false
    t.bigint "from_state_id"
    t.bigint "to_state_id", null: false
    t.string "action_code", null: false
    t.bigint "performed_by_id", null: false
    t.bigint "organization_id"
    t.text "reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_state_id"], name: "index_process_transitions_on_from_state_id"
    t.index ["organization_id"], name: "index_process_transitions_on_organization_id"
    t.index ["performed_by_id"], name: "index_process_transitions_on_performed_by_id"
    t.index ["process_id", "created_at"], name: "index_process_transitions_on_process_id_and_created_at"
    t.index ["process_id"], name: "index_process_transitions_on_process_id"
    t.index ["to_state_id"], name: "index_process_transitions_on_to_state_id"
  end

  create_table "process_types", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "numero", null: false
    t.integer "ano", null: false
    t.string "numero_mp"
    t.string "titulo", null: false
    t.text "resumo"
    t.bigint "process_type_id", null: false
    t.bigint "process_nature_id", null: false
    t.bigint "process_origin_id", null: false
    t.bigint "process_priority_id", null: false
    t.bigint "confidentiality_level_id", null: false
    t.bigint "process_state_id", null: false
    t.datetime "data_entrada", null: false
    t.datetime "data_registo", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organizacao_id"
    t.bigint "responsavel_id"
    t.index ["confidentiality_level_id"], name: "index_processes_on_confidentiality_level_id"
    t.index ["created_by_id"], name: "index_processes_on_created_by_id"
    t.index ["numero", "ano"], name: "index_processes_on_numero_and_ano", unique: true
    t.index ["numero"], name: "index_processes_on_numero"
    t.index ["organizacao_id"], name: "index_processes_on_organizacao_id"
    t.index ["process_nature_id"], name: "index_processes_on_process_nature_id"
    t.index ["process_origin_id"], name: "index_processes_on_process_origin_id"
    t.index ["process_priority_id"], name: "index_processes_on_process_priority_id"
    t.index ["process_state_id"], name: "index_processes_on_process_state_id"
    t.index ["process_type_id"], name: "index_processes_on_process_type_id"
    t.index ["responsavel_id"], name: "index_processes_on_responsavel_id"
    t.index ["titulo"], name: "index_processes_on_titulo"
    t.index ["updated_by_id"], name: "index_processes_on_updated_by_id"
    t.index ["uuid"], name: "index_processes_on_uuid", unique: true
  end

  create_table "profile_capabilities", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "capability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sip_processes", force: :cascade do |t|
    t.string "numero"
    t.integer "tipo_id"
    t.string "origem"
    t.string "estado"
    t.string "prioridade"
    t.date "prazo"
    t.integer "organizacao_id"
    t.integer "responsavel_id"
    t.integer "criador_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_assignments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.integer "profile_id"
    t.string "role"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.integer "organization_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflow_transitions", force: :cascade do |t|
    t.integer "process_id"
    t.string "from_state"
    t.string "to_state"
    t.string "action"
    t.integer "actor_id"
    t.string "required_capability"
    t.text "scope_rule"
    t.text "observacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "deadline_suspensions", "process_deadlines"
  add_foreign_key "deadline_suspensions", "users", column: "created_by_id"
  add_foreign_key "diligences", "diligence_types", column: "diligencia_type_id"
  add_foreign_key "person_addresses", "addresses"
  add_foreign_key "person_addresses", "people"
  add_foreign_key "person_contacts", "people"
  add_foreign_key "person_parental_relations", "people"
  add_foreign_key "person_parental_relations", "people", column: "parent_id"
  add_foreign_key "process_audit_events", "processes"
  add_foreign_key "process_audit_events", "users", column: "actor_id"
  add_foreign_key "process_closures", "processes"
  add_foreign_key "process_closures", "users", column: "closed_by_id"
  add_foreign_key "process_deadlines", "processes"
  add_foreign_key "process_deadlines", "users", column: "created_by_id"
  add_foreign_key "process_legal_classifications", "legal_references"
  add_foreign_key "process_legal_classifications", "processes"
  add_foreign_key "process_legal_classifications", "users", column: "created_by_id"
  add_foreign_key "process_locations", "organizations"
  add_foreign_key "process_locations", "processes"
  add_foreign_key "process_locations", "users"
  add_foreign_key "process_locations", "users", column: "created_by_id"
  add_foreign_key "process_movements", "organizations", column: "from_organization_id"
  add_foreign_key "process_movements", "organizations", column: "to_organization_id"
  add_foreign_key "process_movements", "processes"
  add_foreign_key "process_movements", "users", column: "from_user_id"
  add_foreign_key "process_movements", "users", column: "performed_by_id"
  add_foreign_key "process_movements", "users", column: "to_user_id"
  add_foreign_key "process_parties", "party_types"
  add_foreign_key "process_parties", "people"
  add_foreign_key "process_parties", "processes"
  add_foreign_key "process_parties", "users", column: "created_by_id"
  add_foreign_key "process_reopenings", "processes"
  add_foreign_key "process_reopenings", "users", column: "reopened_by_id"
  add_foreign_key "process_state_transitions", "process_states", column: "from_state_id"
  add_foreign_key "process_state_transitions", "process_states", column: "to_state_id"
  add_foreign_key "process_transitions", "organizations"
  add_foreign_key "process_transitions", "process_states", column: "from_state_id"
  add_foreign_key "process_transitions", "process_states", column: "to_state_id"
  add_foreign_key "process_transitions", "processes"
  add_foreign_key "process_transitions", "users", column: "performed_by_id"
  add_foreign_key "processes", "organizations", column: "organizacao_id"
  add_foreign_key "processes", "users", column: "responsavel_id"
end
