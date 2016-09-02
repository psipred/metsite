class CreateModelTypes < ActiveRecord::Migration
  def self.up
    create_table :model_types do |t|
      t.column :name, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :model_types
  end
end
