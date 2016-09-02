class CreateTestModels < ActiveRecord::Migration
  def self.up
    create_table :test_models do |t|
      t.column :pdb, :binary,         :limit => 16.megabytes
      t.column :created_at, :datetime
      t.column :alternate_sequence, :binary
      t.column :test_entry_id, :integer
      t.column :model_type_id, :integer
      t.column :job_id,         :integer
    end
  end

  def self.down
    drop_table :test_models
  end
end
