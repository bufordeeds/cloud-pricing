class CreatePricingImports < ActiveRecord::Migration[7.2]
  def change
    create_table :pricing_imports do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :records_imported, default: 0
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
