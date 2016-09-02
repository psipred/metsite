class LogResult < ActiveRecord::Base
  belongs_to :resultable, :polymorphic => true
  CONTENT_TYPE = "text/plain"
  SUPPORTED_TYPES = [ 3, 4]

  def parse_status(job_status)
    self.style = job_status.status

    if (!job_status.data.nil?)
      if job_status.status_class != 3
        self.filename = "debug_log_#{self.id}.txt"
      else
        self.filename = "error_log_#{self.id}.txt"
      end
      
      self.data = job_status.data
    end

    self.save
  end
end
