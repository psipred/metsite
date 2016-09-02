class JobMailer < ActionMailer::Base
  default :from => "psipred@cs.ucl.ac.uk"
  
  
  #TODO: admin_email = "d.buchan@cs.ucl.ac.uk"
  
  #TODO: body parameter is useless: @txtbody should be set here or in the txt views and/or synchronised with html body!
  #      Also: results URL in the view should be probably formatted using variables as in views/psipred/submit.html.erb
  def newpsi(job, body)
    @subject    = "PSIPRED Sequence analysis results for job ID:#{job.UUID}/#{job.name}"
    @txtbody    = body
    @jobUUID    = job.UUID
    @recipients = job.address
	  mail(:to => @recipients, :subject => @subject)
  end

  #TODO: body parameter is useless: @txtbody should be set here or in the txt views and/or synchronised with html body!
  #      Also: results URL in the view should be probably formatted using variables as in views/psipred/submit.html.erb
  def struct(job, body)
    @subject    = "PSIPRED Structure analysis results for job ID:#{job.UUID}/#{job.name}"
    @txtbody    = body
    @jobUUID    = job.UUID
    @recipients = job.address
    #puts @recipients + " " + @body + @subject  
    mail(:to => @recipients, :subject => @subject)
  end

  
  def completion(job, model)
    @subject    = "Results for ID:#{job.id}/#{job.name}"
	@job  		= job
	@model		= model
    @recipients = ["psipred@cs.ucl.ac.uk", job.address]
    
	mail(:to => @recipients, :subject => @subject)
  end
  
  def casp_request(new_casp_job)
    @subject    = "New Job #{new_casp_job.id}"
    @casp_job   = new_casp_job
    @recipients = "psipred@cs.ucl.ac.uk"
  	
	mail(:to => @recipients, :subject => @subject)
  end

  def failure(job)
    @subject    = "Job Failure for #{job.id}"
    @body       = {:job => job}
    @recipients = "psipred@cs.ucl.ac.uk"
    
	mail(:to => @recipients, :subject => @subject)
  end

  def serverfailure(server)
    @subject    = "Server #{server} has gone away"
    @body       = "Warning Will Robinson; A Server has gone away!"
    @recipients = "psipred@cs.ucl.ac.uk"
    
	mail(:to => @recipients, :subject => @subject)
  end

  def databasefailure()
    @subject    = "The database has gone away"
    @body       = "Warning Will Robinson; The database has gone away!"
    @recipients = "psipred@cs.ucl.ac.uk"

	mail(:to => @recipients, :subject => @subject)
  end

  def insertfailure(id,jobclass,status)
    @subject    = "Runner failed to insert results for job id:" + id.to_s
    @body       = "Results could not be inserted to request_result " + jobclass.to_s + " " + status.to_s
    @recipients = "psipred@cs.ucl.ac.uk"
    
	mail(:to => @recipients, :subject => @subject)
  end
  
  def statuserror(server,status)
    @subject    = "Status Error, status set to #{status}"
    @body       = "A job with an erroneous status has been found"
    @recipients = "psipred@cs.ucl.ac.uk"
	
	mail(:to => @recipients, :subject => @subject)
  end

  def error(job, body)
    @subject    = "Job failure for job ID:#{job.UUID}/#{job.name}"
    message ="";
    
	if(job.Type =~ /mempack/)
      message = body + "\n\n Full details of the failed job are available from http://bioinf.cs.ucl.ac.uk/bio_serf/public_status/#{job.id}\n If you believe that this job has failed because of a problem with our server then please email us."
    else
      message = body + "\n\nIf you experience repeated or multiple job failures please email us."
    end
    
	@body = message
    @recipients = job.address

	mail(:to => @recipients, :subject => @subject)

  end
end
