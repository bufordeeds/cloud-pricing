class CreateLlmProviders < ActiveRecord::Migration[7.2]
  def change
    create_table :llm_providers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color

      t.timestamps
    end

    add_index :llm_providers, :slug, unique: true
  end
end
