module ControllerTools
#this module bundles up some methods that both the psipred and structure controllers both need

  def setIP
    #@job.ip = request.remote_ip, find out from where our user has submitted their job
    tmp_ip = request.env["HTTP_X_FORWARDED_FOR"]
    if(tmp_ip =~ /(\d+\.\d+\.\d+\.\d+)$/)
      tmp_ip = $1;
    else
      tmp_ip = request.remote_ip
    end
    return tmp_ip
  end
  
  def overrider(name, value)
    override = JobConfigOverride.create()
    override.job_id = @job.id
    override.key = name
    override.value = value
    override.save!
  end
  
end