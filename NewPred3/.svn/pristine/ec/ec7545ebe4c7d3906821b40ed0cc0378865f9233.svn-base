class CreateJobConfigurations < ActiveRecord::Migration
  
  def self.up
    create_table :job_configurations do |t|
      t.column :name,           :string
      t.column :comment,        :string
      t.column :active,         :boolean
    end
  end

  def self.down
    drop_table :job_configurations
  end
end
