class CreateTestSets < ActiveRecord::Migration
  def self.up
    create_table :test_sets do |t|
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :description, :string
    end

    # for has_and_belongs_to_many association
    create_table :test_entries_test_sets, :id=>false do |t|
      t.column :test_entry_id,  :integer, :null => false
      t.column :test_set_id,    :integer, :null => false
    end
  end

  def self.down
    drop_table :test_sets
    drop_table :test_entries_test_sets
  end
end
