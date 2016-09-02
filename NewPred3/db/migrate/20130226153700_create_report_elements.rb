class CreateReportElements < ActiveRecord::Migration
  def self.up
    create_table :report_elements do |t|
      t.column :test_model_id, :integer
      t.column :report_id, :integer
      t.column :data, :binary
      t.column :score, :float
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :report_elements
  end
end
