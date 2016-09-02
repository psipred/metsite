class CreatePdbResults < ActiveRecord::Migration
  def self.up
    create_table :pdb_results do |t|
      t.string :filename
      t.date :created_on
      t.binary :data,      :limit => 16.megabytes
      t.integer :category
      
      t.references :resultable, :polymorphic => true

      t.timestamps
    end

    add_index :pdb_results, :category
    add_index :pdb_results, [:resultable_id, :resultable_type]
  end

  def self.down
    remove_index :pdb_results, :category
    remove_index :pdb_results, [:resultable_id, :resultable_type]

    drop_table :pdb_results
  end
end
