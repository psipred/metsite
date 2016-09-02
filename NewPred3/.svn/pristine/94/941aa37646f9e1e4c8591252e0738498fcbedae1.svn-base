class CreatePendingRuns < ActiveRecord::Migration
  def self.up
    create_table :pending_runs do |t|
      t.column :test_run_id, :integer
      t.column :created_at, :date
      t.column :name, :string
    end
    # for has_and_belongs_to_many association
    create_table :jobs_pending_runs, :id => false do |t|
      t.column :job_id,       :integer, :null => false
      t.column :pending_run_id,  :integer, :null => false
    end
  end

  def self.down
    drop_table :pending_runs
    drop_table :jobs_pending_runs
  end
end
