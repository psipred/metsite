class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.column :binary, :string
      t.column :created_at, :datetime
      t.column :name, :string
      t.column :description, :string
      t.column :last_run, :datetime
      t.column :ref_model_type_id, :integer
      t.column :has_score, :boolean
    end
    create_table :model_types_reports, :id => false do |t|
      t.column :model_type_id, :integer
      t.column :report_id, :integer
    end
    
  end

  def self.down
    drop_table :reports
    drop_table :model_types_reports
  end
end
