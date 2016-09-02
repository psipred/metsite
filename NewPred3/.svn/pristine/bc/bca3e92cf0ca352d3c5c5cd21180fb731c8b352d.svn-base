class Server < ActiveRecord::Base
  has_and_belongs_to_many :job_configurations
  has_many :jobs
  attr_accessible :name, :address, :description, :service
  
  require 'new_pred_client'
  
  def get_connection
    logger.info "Making client to #{address} on service #{service}" 
    npc = NewPredClient.new(address, service)
    return npc
  end
end
