class Genome3d < ActiveRecord::Base
  
  belongs_to  :uniprot
  
  scope :by_uniprot_id, (lambda do |id|
    { :conditions => ["uniprot_id=?",id]}
  end )
  
end