class AddMemembedJobType < ActiveRecord::Migration
  def self.up
    add_column :jobs, :program_memembed, :integer, :default => 0
  end

  def self.down
    remove_column :jobs, :program_memembed
  end
end