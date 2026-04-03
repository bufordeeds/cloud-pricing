class RenameLlmModelNameToName < ActiveRecord::Migration[7.2]
  def change
    rename_column :llm_models, :model_name, :name
  end
end
