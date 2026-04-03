class CreateInstances < ActiveRecord::Migration[7.2]
  def change
    create_table :instances do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :instance_type, null: false
      t.string :family
      t.integer :vcpus, null: false
      t.float :memory_gb, null: false
      t.decimal :price_per_hour, precision: 10, scale: 6, null: false
      t.string :region, null: false, default: "us-east-1"
      t.string :operating_system, default: "Linux"
      t.jsonb :raw_attributes, default: {}

      t.timestamps
    end

    add_index :instances, [ :provider_id, :instance_type, :region ], unique: true
    add_index :instances, :vcpus
    add_index :instances, :memory_gb
    add_index :instances, :price_per_hour
  end
end
