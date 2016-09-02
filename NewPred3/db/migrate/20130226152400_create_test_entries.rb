class CreateTestEntries < ActiveRecord::Migration
  def self.up
    create_table :test_entries do |t|
      t.column :sequence, :binary
      t.column :name, :string
      t.column :comment, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :test_entries
  end
end
