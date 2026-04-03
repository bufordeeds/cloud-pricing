class CreateApiKeys < ActiveRecord::Migration[7.2]
  def change
    create_table :api_keys do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :token_digest
      t.string :token_prefix
      t.string :status, null: false, default: "pending"
      t.text :notes
      t.integer :request_count, default: 0, null: false
      t.datetime :last_request_at
      t.datetime :approved_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :api_keys, :token_digest, unique: true
    add_index :api_keys, :token_prefix, unique: true
    add_index :api_keys, :email
    add_index :api_keys, :status
  end
end
