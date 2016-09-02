class CreateFfExpansions < ActiveRecord::Migration
  def self.up
    create_table :ff_expansions do |t|
      t.text :overrides
      t.text :values, :limit => 16777215

      t.timestamps
    end
  end

  def self.down
    drop_table :ff_expansions
  end
end
