class CreateThumbnails < ActiveRecord::Migration
  def self.up
    create_table :thumbnails do |t|
      t.binary :data,      :limit => 2.megabytes
      t.integer :x
      t.integer :y
      t.integer :request_result_id

      t.timestamps
    end
    add_index :thumbnails, :request_result_id
  end

  def self.down
    remove_index :thumbnails, :request_result_id
    drop_table :thumbnails
  end
end
