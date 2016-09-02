class CreateCheckpointCaches < ActiveRecord::Migration
  def self.up
    create_table :check_point_caches do |t|
      t.column :MD5,          :string
      t.column :usages,       :integer
      t.column :created_at,   :datetime
      t.column :data,         :binary,      :limit => 20.megabytes
      t.column :chk_type,     "ENUM('plus3ItsFiltered', 'plus6ItsFiltered', 'plus3ItsUnfiltered','plusDompred','pgp3ItsUnFiltered')"

    end

    add_index :check_point_caches, [:MD5,:created_at]

  end

  def self.down
    drop_table :check_point_caches
  end
end
