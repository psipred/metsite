class CreateConfigurationEntries < ActiveRecord::Migration
  def self.up
    create_table :configuration_entries do |t|
      t.column :key, :string
      t.column :value, :string
      t.column :job_configuration_id, :integer
    end
	add_index :configuration_entries, :key
  end
  
  
  def self.down
    drop_table :configuration_entries
  end
end
