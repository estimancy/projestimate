class CreateStatusTransitions < ActiveRecord::Migration
  def change
    create_table :status_transitions do |t|
      t.integer :from_transition_status_id
      t.integer :to_transition_status_id

      t.timestamps
    end
  end
end
