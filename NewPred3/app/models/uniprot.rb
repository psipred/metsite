class Uniprot < ActiveRecord::Base
  
  has_many    :genome3ds
  
  scope :by_uniprot_id, (lambda do |id|
    { :conditions => ["uniprot_id=?",id]}
  end )
  
end