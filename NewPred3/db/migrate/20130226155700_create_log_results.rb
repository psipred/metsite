class CreateLogResults < ActiveRecord::Migration
  def self.up
    create_table :log_results do |t|
      t.string :filename
      t.date :created_on
      t.binary :data,      :limit => 16.megabytes
      t.string :style

      t.references :resultable, :polymorphic => true
      
      t.timestamps
    end

    add_index :log_results, :style
    add_index :log_results, [:resultable_id, :resultable_type]
  end

  def self.down
    remove_index :log_results, :style
    remove_index :log_results, [:resultable_id, :resultable_type]

    drop_table :log_results
  end
end
