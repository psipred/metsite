class CreateTestRuns < ActiveRecord::Migration
  def self.up
    create_table :test_runs do |t|
      t.column :job_type, :string
      t.column :created_at, :datetime
      t.column :name, :string
      t.column :description, :string
      t.column :configuration_id, :integer
      t.column :test_set_id,  :integer
    end

  end

  def self.down
    drop_table :test_runs
  end
end
