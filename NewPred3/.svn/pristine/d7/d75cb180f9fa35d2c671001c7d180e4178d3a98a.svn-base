class CreateGenome3d < ActiveRecord::Migration
  def self.up
    create_table :genome3ds do |t|
      t.column :uniprot_id,      :string
      t.column :status,       :string
      t.column :status_class, :integer
      t.column :created_at,   :datetime
      t.column :content_type, :string
      t.column :content_name, :string
      t.column :data,         :binary,      :limit => 16.megabytes
    end
  
    create_table :uniprots do |t|
      t.column :uniprot_id,    :string
      t.column :QueryString,   :binary, {:limit => 20.megabytes}
    end 
  
    add_index :genome3ds, :uniprot_id
    add_index :genome3ds, :status_class
    add_index :genome3ds, [:uniprot_id, :status_class]
    add_index :uniprots,  :uniprot_id
  
  end

  def self.down
    drop_table :genome3ds
    drop_table :uniprots
  end
end
