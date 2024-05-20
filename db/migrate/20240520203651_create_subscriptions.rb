class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :subscription_id, null: false
      t.integer :status

      t.timestamps
    end

    add_index :subscriptions, :subscription_id, unique: true
  end
end
