class CreateJobConfigOverrides < ActiveRecord::Migration
  def self.up
    create_table :job_config_overrides do |t|
      t.column :key, :string
      t.column :value, :binary,      :limit => 20.megabytes
      t.column :job_id, :integer
    end
  end

  def self.down
    drop_table :job_config_overrides
  end
end
