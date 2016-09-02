# To change this template, choose Tools | Templates
# and open the template in the editor.

module GenericMixin

    def before_save_validate
  
    end

    def init_result_handle

    end
    
    # replaces the former poll_results loop in job class with handler for each result type
    def handle_result(job_status)
      newstatus = RequestResult.create
      self.request_results << newstatus
      newstatus.status_class = job_status.status_class
      newstatus.status = job_status.status

      case job_status.status_class.to_i
      
      when 2 # flow control info
        self.state = job_status.status_code
        self.save!
        
        if (job_status.status_code == 4)
          @end_poll = true
          self.job_finish_handler
        end

      when 3 # error log info
        if (!job_status.data.nil?)
          newstatus.content_type = "text/plain"
          newstatus.content_name = "error_log_#{newstatus.id}.txt"
          newstatus.data = job_status.data
        end
        JobMailer.error(self, job_status.status).deliver if !self.address.nil?
      
      when 4 # debug log info
        if (!job_status.data.nil?)
          newstatus.content_type = "text/plain"
          newstatus.content_name = "debug_log_#{newstatus.id}.txt"
          newstatus.data = job_status.data
        end
      when 5 # HTML result
        newstatus.content_type = "text/html"
        newstatus.content_name = job_status.status
        newstatus.data = job_status.data

      when 6  # pdb_result
        newstatus.status = "pdb file result"
        newstatus.content_type = "application/octet-stream"
        newstatus.content_name = job_status.status
        newstatus.data = job_status.data
      
      when 7 # intermediate pdb files
        newstatus.status = "intermediate pdb file result"
        newstatus.content_type = "application/octet-stream"
        newstatus.content_name = job_status.status
        newstatus.data = job_status.data
      end
    end

    def before_result_save

    end

    def job_start_handler

    end

    def job_error_handler

    end

    def job_finish_handler

    end

    def getJobType
      self.Type
    end
end
