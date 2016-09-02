class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.column :Type,             :string
      t.column :QueryString,      :binary, {:limit => 20.megabytes}
      t.column :name,             :string
	  t.column :address,          :string
      t.timestamps
      t.column :user_id,          :integer
      t.column :job_configuration_id, :integer
      t.column :server_id,        :integer
      t.column :ip,               :string
      t.column :state,            :integer
	  t.column :ff_expansion_id,  :integer
	  t.column :program_psipred, :integer, :default => 0
      t.column :program_disopred, :integer, :default => 0
      t.column :program_mgenthreader, :integer, :default => 0
      t.column :program_svmmemsat, :integer, :default => 0
      t.column :program_bioserf, :integer, :default => 0
      t.column :program_dompred, :integer, :default => 0
      t.column :program_ffpred, :integer, :default => 0
      t.column :program_genthreader, :integer, :default => 0
      t.column :program_mempack, :integer, :default => 0
      t.column :program_domthreader, :integer, :default => 0
	  t.column :program_metsite, :integer, :default => 0
      t.column :program_maketdb, :integer, :default => 0
      t.column :program_hspred, :integer, :default => 0
	  t.column :UUID, "VARCHAR(40)"
    end
	add_index :jobs, :name
	add_index :jobs, :state
	add_index :jobs, :created_at
	add_index :jobs, :UUID
	
  end

  def self.down
    drop_table :jobs
  end
end
