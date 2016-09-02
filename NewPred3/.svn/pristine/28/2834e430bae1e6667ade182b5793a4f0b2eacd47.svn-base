class PdbResult < ActiveRecord::Base
  belongs_to :resultable, :polymorphic => true

  CONTENT_TYPE = "application/octet-stream"
  SUPPORTED_TYPES = [ 6, 7]
  
  def parse_status(job_status)
      self.category = job_status.status_class.to_i
      self.data = job_status.data
      self.filename = job_status.status

      self.save
  end

end
