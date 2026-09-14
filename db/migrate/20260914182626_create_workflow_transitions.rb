class CreateWorkflowTransitions < ActiveRecord::Migration[8.0]
  def change
    create_table :workflow_transitions do |t|
      t.integer :process_id
      t.string :from_state
      t.string :to_state
      t.string :action
      t.integer :actor_id
      t.string :required_capability
      t.text :scope_rule
      t.text :observacao

      t.timestamps
    end
  end
end
