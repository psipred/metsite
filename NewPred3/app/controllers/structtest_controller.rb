class StructtestController < ApplicationController

  require 'rubygems'
  require 'uuidtools'
  require "unicode_utils/upcase"
  #before_filter :login_from_cookie
  
  def index
    #if (logged_in?)
    #  @login = self.current_user.login
    #end

    #Allow external links to auto fill some features.
     @pdbFile = params[:pdbFile]
    if @pdbFile.nil?
      @pdbFile = ''
    end

    @type = params[:program]
    if @type.nil?
      @type = 'hspred'
    end

    @address = params[:email]
    if @address.nil?
      @address = ''
    end

    @subject = params[:name]
    if @subject.nil?
      @subject = ''
    end

    @chain = params[:chain]
    if @chain.nil?
      @chain = ''
    end

     @chainsA = params[:chainsA]
    if @chainsA.nil?
      @chainsA = ''
    end

     @chainsB = params[:chainsB]
    if @chainsB.nil?
      @chainsB = ''
    end

    @service_name = "structtest"# service name for the application layout header
    redirect_to :controller => 'structure', :action => 'index'
  end
  
  def submit

    #set some defaults values just in case
     @pdbFile = params[:pdbFile]
    if @pdbFile.nil?
      @pdbFile = ''
    end

    @type = params[:program]
    if @type.nil?
      @type = 'hspred'
    end

    @address = params[:email]
    if @address.nil?
      @address = ''
    end

    @subject = params[:name]
    if @subject.nil?
      @subject = ''
    end

    @chain = params[:chain]
    if @chain.nil?
      @chain = ''
    end

     @chainsA = params[:chainsA]
    if @chainsA.nil?
      @chainsA = ''
    end

     @chainsB = params[:chainsB]
    if @chainsB.nil?
      @chainsB = ''
    end

    @service_name = "structtest"# service name for the application layout header.

    #create a new job object
    @job = Job.new()

    #Assign the basic job information
    file_data = params[:pdbFile]
    #file data here is a File object
    file_string = ""
    file_data.each do |line|
      file_string = "#{file_string}#{line}"
    end

    @job.QueryString = file_string
    @job.address = params[:email]
    @job.name = params[:name]
    @job.Type = "structJob"
    @job.UUID  = UUIDTools::UUID.timestamp_create().to_s
    #Here we send which jobs we're running to the jobs table
    #Down below we'll also pass these as job_overrides, a little inelegant but the process already exists for passing arbitrary values the backend
    
    if (defined?(params[:program_hspred])).nil?
      @job.program_hspred = 0
    else
      @job.program_hspred = params[:program_hspred]
    end
    if (defined?(params[:program_metsite])).nil?
      @job.program_metsite = 0
    else
      @job.program_metsite = params[:program_metsite]
    end
    if (defined?(params[:program_maketdb])).nil?
      @job.program_maketdb = 0
    else  
      @job.program_maketdb = params[:program_maketdb]
    end
    
    if(@job.program_hspred == 0 && @job.program_metsite == 0 && @job.program_maketdb == 0)
      @job.program_hspred = 1
    end

    #@job.ip = request.remote_ip
    tmp_ip = request.env["HTTP_X_FORWARDED_FOR"]
    if(tmp_ip =~ /(\d+\.\d+\.\d+\.\d+)$/)
      tmp_ip = $1;
    else
      tmp_ip = request.remote_ip
    end
    @job.ip = tmp_ip

    #Set the user ID
    @job.user_id = setUID(@job.address)

    #for abusers or regular users we take a job count
    job_count = countJobs(@job.ip)

    #set the current configurations
    curconfig = Configuration.find_by_name(@job.Type)
    @job.configuration_id = curconfig.id
        
    #this creates a global variable with the password value set so that the validate method in the job model can see it. Bit of
    #an ugly hack but I couldn't immediate see a better way to do it.
    $passwd = params[:passwd]
    logger.info("Jobs" + job_count.to_s)
    #attempt to save, if some data is missing from the form, throw the form again with the appropriate warnings
    respond_to do |format|
      begin

        if(job_count >= 10 && @job.user_id != 0)
          @error_message = "Your IP address has 10 live jobs running.  Please wait until your jobs have finished before submitting more. "
          format.html { render :action => "error"}
        elsif(@job.user_id == 0 && job_count >= 20)
          @error_message = "Your IP address has 20 live jobs running.  Please wait until your jobs have finished before submitting more. "
          format.html { render :action => "error"}
        elsif(@job.user_id == 11)
          @error_message = "Your IP address has been banned from submitting jobs due to misuse of our server. If you feel this is an error or you wish to restablish access please contact us."
          format.html { render :action => "error"}
        else
#
         @job.save!
          logger.info("#{@job.id}")
          #create an object for each override settings.  Then save all the settings that will override the job defaults
          #kind of ugly. Is there a cleaner way to do this?
          #4 years later and I still can't think of a more elegant way of doing this. I suspect the issue is that the whole
          #shebang would need redoing.
          assignOverrides()
#
          #actually submit the job (expect and array of job objects as the function isn't overloaded)
          @job.submit_jobs([@job])
#
          #format output
          format.html
          
          #add line to throw XML for our upcoming webservice
        end
      rescue Exception => e
        #format.html { render :action => "error"}
        #@error_message = e.to_s + @job.QueryString
        format.html { render :action => "error"}
        #format.html { render :action => "index"}
        #add line to throw XML for our upcoming webservice
      end
    end

    
  end

  #rather dull function that works through all the form elements and adds them a job config overrides
  #create an object for each override settings.  Then save all the settings that will override the job defaults
  #kind of ugly. Is there a cleaner way to do this?
  #4 years later and I still can't think of a more elegant way of doing this. I suspect the issue is that the whole
  #shebang would need doing.
  def overrider(name, value)
    override = JobConfigOverride.create()
    override.job_id = @job.id
    override.key = name
    override.value = value
    override.save!
  end

  def assignOverrides
    overrider("program_hspred",@job.program_hspred)
    overrider("program_metsite",@job.program_metsite)
    overrider("program_maketdb",@job.program_maketdb)

    #metsite overrides
    overrider("false_positive_setting",params[:fpr])
    overrider("metal_site_classifier",params[:metType])
    chain = params[:chain]
    chain.upcase!
    chain.gsub!(/\n|\s/, "")
    overrider("chain_id",chain)

    #hspred overrides
    chainsA = params[:chainsA]
    chainsA.upcase!
    chainsA.gsub!(/\n|\s/, "")
    chainsA.gsub!(/\W|\d/, "")
    chainsB = params[:chainsB]
    chainsB.upcase!
    chainsB.gsub!(/\n|\s/, "")
    chainsB.gsub!(/\W|\d/, "")
    overrider("chains_a",chainsA)
    overrider("chains_b",chainsB)


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
      if(email =~ /predictioncenter\.org/)
        #set to casp user id: run priority 8
        return 4
      elsif(email =~ /@ucl\.ac\.uk/)
        #set to UCL user id: run priority 8
        return 5
      elsif email =~ /@cs\.ucl\.ac\.uk/
        #set to CS UCL user id: run priority 10
        return 6
      elsif email =~ /\.gr\.[a-z][a-z]\z/
        #set to commercial subscriber ID: run priority 5
        return 7
        #elsif @job.address =~ /t\.polen@fz-juelich\.de/
        #list of banned users.
        # @job.user_id = 11
      elsif @job.address =~ /hline\.org|ijmr\.in/
        #set to abusers ID: run priority 1
        return 8
      else
        #Run at default run level: priority 2
        return 0
      end
    #end
  end

  def result
    @service_name = "structtest"

    #getting the data for the incoming job ID, the exception handling allows us to handle throwing an error view if the ID
    #is wrong
    begin
      id = params[:id]
      @job_tmp = Job.find(:all, :conditions => "UUID=\"#{id}\"")
      @job = @job_tmp[0]

      @job_results = @job.request_results.find(:all)
      
      #get any job config overrides parameters that the view might need to use
      @result_override = @job.job_config_overrides.find(:all, :conditions => "job_config_overrides.key = 'result_filter_setting'")
      @table_rows = {}
      @alignments = {}
      @result_filter = ''
      @result_override.each do |filter_state|
        @result_filter = filter_state.value
      end

     
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

  def ongoing
    @service_name = "structtest"
  end

  def image
    @service_name = "structtest"
    @imgid = params[:imageid]
  end

end
