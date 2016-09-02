class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.column :name, :string
      t.column :address, :string
      t.column :service, :string
      t.column :description, :string
	    t.column :maxjobs, :integer, :default => 1000
	  
    end
    create_table :job_configurations_servers, :id => false do |t|
      t.column :job_configuration_id, :integer
      t.column :server_id, :integer
    end
    
  end

  def self.down
    drop_table :servers
    drop_table :job_configurations_servers
  end
end
