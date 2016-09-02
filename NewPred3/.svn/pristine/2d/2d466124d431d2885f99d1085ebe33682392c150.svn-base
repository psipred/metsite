class CreateRequestResults < ActiveRecord::Migration
  def self.up
    create_table :request_results do |t|
      t.column :job_id,       :integer
      t.column :status,       :string
      t.column :status_class, :integer
      t.column :created_at,   :datetime
      t.column :content_type, :string
      t.column :content_name, :string
      t.column :data,         :binary,      :limit => 16.megabytes
    end
	
	add_index :request_results, :job_id
    add_index :request_results, :status_class
    add_index :request_results, [:job_id, :status_class]
	
  end

  def self.down
    drop_table :request_results
  end
end
