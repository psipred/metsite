class SimpleModellerController < ApplicationController

  require "open3"
  include Open3
  require "pp"

  def index
    @service_name = "simple_modeller"
    @error_message = "this is not the page you are looking for"
      redirect_to("/psipredtest")
  end

  def submit
    #TODO: sanity check all params in params[]
    
    @service_name = "simple_modeller"
    

    #dec;are new job instance
    @job = Job.new()

    @mod = params[:mod]
    if @mod.nil?
      @mod = 0
    end

    @mod_key = params[:modeller]
    if @mod == 1
      @mod_key="MODELIRANJE"
    end

    #set some @job things
    #hardset the job type (can't run our other jobs types from this controller)
    @job.Type = "SimpleModeller"
    #set the given job ID
    @job.QueryString = "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
    @job.name = params[:name]
    curconfig = JobConfiguration.find_by_name("simpleModeller")
	@job.job_configuration_id = curconfig.id
    @job.user_id = 0

	#@job.ip = request.remote_ip, find out from where our user has submitted their job
    tmp_ip = request.env["HTTP_X_FORWARDED_FOR"]
    if(tmp_ip =~ /(\d+\.\d+\.\d+\.\d+)$/)
      tmp_ip = $1;
    else
      tmp_ip = request.remote_ip
    end
    @job.ip = tmp_ip

    @job.address = nil

    @model_test = 1
    ENV['KEY_MODELLER9v3'] = params[:modeller]
    input, stdout, stderr = Open3.popen3("/webdata/binaries/current/test_modeller/bin/mod9v3 /webdata/binaries/current/test_modeller/examples/commands/build_profile.py")
    @output = stderr.read
    if @output =~ /Invalid license key/
      @model_test = 0
    end


    #Test the MODELLER key is valid if a BioSerf job has been requested
    @model_test=1
    @model_test=testModellerKey(@mod_key)
    
    #Set the user ID
    @job.user_id = setUID(@job.address)

    #for abusers or regular users we take a job count
    job_count = countJobs(@job.ip)


    respond_to do |format|
    
      begin

      if @model_test == 0
          @error_message = "Modeller Licence Key invalid"
          format.html { render :action => "error"}
        elsif(job_count >= 10 && @job.user_id != 0)
          @error_message = "Your IP address has 10 live jobs running.  Please wait until your jobs have finished before submitting more. "
          format.html { render :action => "error"}
        elsif(@job.user_id == 0 && job_count >= 20)
          @error_message = "Your IP address has 20 live jobs running.  Please wait until your jobs have finished before submitting more. "
          format.html { render :action => "error"}
        elsif(@job.user_id == 11)
          @error_message = "Your IP address has been banned from submitting jobs due to misuse of our server. If you feel this is an error or you wish to restablish access please contact us."
          format.html { render :action => "error"}
        else
      	@job.save!

          pdbOverride = JobConfigOverride.create()
          pdbOverride.job_id = @job.id
          pdbOverride.key = "TEMPLATE"
          pdbOverride.value = params[:template]
          pdbOverride.save!

          pdbOverride = JobConfigOverride.create()
          pdbOverride.job_id = @job.id
          pdbOverride.key = "PIR"
		  tmp_alignment = params[:alignment]
		  tmp_alignment.gsub!(/\n|\r|\n\r|\r\n/, '\\'+'n')
          pdbOverride.value = tmp_alignment
		  pdbOverride.save!

          pdbOverride = JobConfigOverride.create()
          pdbOverride.job_id = @job.id
          pdbOverride.key = "PDB_TYPE"
          pdbOverride.value = params[:pdb_type]
          pdbOverride.save!

          @job.submit_jobs([@job])
          format.html
      
    	 end
      rescue Exception => e
        @error_message = e.message
        format.html { render :action => "error"}

      end
      
    end

  end

  def ongoing
    @service_name = "simple_modeller"
  end


  def result
    @service_name = "simple_modeller"
    begin
      @job = Job.find(params[:id])
      @job_results = @job.request_results.find(:all)
      #loop through the job states to find out what state the job finished in.  Did it complete?
      job_complete = 0
      @job_results.each do |job_state|
        if (job_state.status =~ /Job Complete/)
         job_complete = 1
        end
        if (job_state.status_class == 3)
          job_complete = 2
          @error_message = job_state.status
        end

      end
    rescue
      job_complete=3
    end

    respond_to do |format|
      
        if(job_complete == 1)
        format.html
      elsif (job_complete == 2)
        format.html { render :action => "error"}
      elsif (job_complete == 3)
        format.html { render :action => "no_id"}
      else
        format.html { render :action => "ongoing"}
      end

        
    end

  end

  #count how many jobs a given IP currently has
  def countJobs(ip)
    count = 0
    running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
    running_jobs.each_with_index do |running, index|
      count = index
    end
    return count
  end

  #Work our what user ID the job should run with at the backend
  def setUID(email)
    #if (logged_in?)
    #  @job.user_id = self.current_user.id
    #  @login = self.current_user.login
    #else
    #  if(email =~ /predictioncenter\.org/)
    #    #set to casp user id: run priority 8
    #    return 4
    #  elsif(email =~ /@ucl\.ac\.uk/)
    #    #set to UCL user id: run priority 8
    #    return 5
    #  elsif email =~ /@cs\.ucl\.ac\.uk/
    #    #set to CS UCL user id: run priority 10
    #    return 6
    #  elsif email =~ /\.gr\.[a-z][a-z]\z/
    #    #set to commercial subscriber ID: run priority 5
    #    return 7
    #    #elsif @job.address =~ /t\.polen@fz-juelich\.de/
    #    #list of banned users.
    #    # @job.user_id = 11
    #  elsif @job.address =~ /hline\.org|ijmr\.in/
    #    #set to abusers ID: run priority 1
    #    return 8
    #  else
    #    #Run at default run level: priority 2
    #    return 0
    #  end
    #end
	return 0
  end

  def testModellerKey(key)
    ENV['KEY_MODELLER9v3'] = key
    input, stdout, stderr = Open3.popen3("/webdata/binaries/current/test_modeller/bin/mod9v3 /webdata/binaries/current/test_modeller/examples/commands/build_profile.py")
    output = stderr.read
    if output =~ /Invalid license key/
      return 0
    else
      return 1
    end
  end

end
