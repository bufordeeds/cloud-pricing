class CreateLlmModels < ActiveRecord::Migration[7.2]
  def change
    create_table :llm_models do |t|
      t.references :llm_provider, null: false, foreign_key: true
      t.string :model_name, null: false
      t.string :model_id, null: false
      t.decimal :input_price_per_mtok, precision: 10, scale: 4
      t.decimal :output_price_per_mtok, precision: 10, scale: 4
      t.integer :context_window
      t.integer :max_output_tokens
      t.boolean :supports_vision, default: false
      t.boolean :supports_tool_use, default: false
      t.boolean :supports_extended_thinking, default: false
      t.date :release_date

      t.timestamps
    end

    add_index :llm_models, [ :llm_provider_id, :model_id ], unique: true
  end
end
