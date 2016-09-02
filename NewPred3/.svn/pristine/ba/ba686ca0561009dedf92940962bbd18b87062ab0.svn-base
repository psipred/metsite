class PsipredtestController < ApplicationController

  #before_filter :login_from_cookie
  require "unicode_utils/upcase"

  def index
    #if (logged_in?)
    #    @login = self.current_user.login
    #end
    @service_name = "psipredtest"# service name for the application layout header

    #Allow external links to auto fill some features.
    @sequence = params[:sequence]
    if @sequence.nil?
      @sequence = ''
    end
    
    @type = params[:program]
    if @type.nil?
      @type = 'psipred'
    end

    @address = params[:email]
    if @address.nil?
      @address = ''
    end

    @subject = params[:subject]
    if @subject.nil?
      @subject = ''
    end

    redirect_to :controller => 'psipred', :action => 'index'
  end
  
  def submit

    #set some defaults values just in case
    @sequence = params[:sequence]
    if @sequence.nil?
      @sequence = ''
    end

    @type = params[:program]
    if @type.nil?
      @type = 'psipred'
    end

    @address = params[:email]
    if @address.nil?
      @address = ''
    end

    @subject = params[:subject]
    if @subject.nil?
      @subject = ''
    end

    if params[:complex].nil?
      params[:complex] = "true"
    end
    if params[:membrane].nil?
      params[:membrane] = "false"
    end
    if params[:coil].nil?
      params[:coil] = "false"
    end

    @service_name = "psipredtest" #service name for the application layout header. Candidate for global variable?

    #create a new job object
    @job = Job.new()

    #Assign the basic job information
    @job.QueryString = params[:sequence]
    @job.address = params[:email]
    @job.name = params[:subject]
    @job.Type = params[:program]
    

    tmp_ip = request.env["HTTP_X_FORWARDED_FOR"]
    if(tmp_ip =~ /(\d+\.\d+\.\d+\.\d+)$/)
      tmp_ip = $1;
    else
      tmp_ip = request.remote_ip
    end
    @job.ip = tmp_ip


      @job_count = 0
     #set which user the job runs as
      #if (logged_in?)
      #  @job.user_id = self.current_user.id
      #  @login = self.current_user.login
      #else
        if(@job.address =~ /predictioncenter\.org/)
          #set to casp user id: run priority 8
          @job.user_id = 4
        elsif(@job.address =~ /@ucl\.ac\.uk/)
          #set to UCL user id: run priority 8
          @job.user_id = 5
        elsif @job.address =~ /@cs\.ucl\.ac\.uk/
          #set to CS UCL user id: run priority 10
          @job.user_id = 6
        elsif @job.address =~ /\.gr\.[a-z][a-z]\z/
          #set to commercial subscriber ID: run priority 5
          @job.user_id = 7
        #elsif @job.address =~ /t\.polen@fz-juelich\.de/
          #list of banned users.
         # @job.user_id = 11
        elsif @job.address =~ /hline\.org|ijmr\.in/
          #set to abusers ID: run priority 1
          @job.user_id = 8
          ip = @job.ip
          running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs.each_with_index do |running, index|
            @job_count = index
          end
        else
          #Run at default run level: priority 2
          @job.user_id = 0
          ip = @job.ip
          @master_ip = @job.ip
          #running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs.each_with_index do |running, index|
            @job_count = index
          end
        end
      #end

    ip = @job.ip
    #running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs.each_with_index do |running, index|
            @job_count = index
          end

    #set the current configurations
    curconfig = Configuration.find_by_name(@job.Type)
    @job.configuration_id = curconfig.id
    
    #if the job is memsat or variants then override the incoming filtering options (i.e. don't do any sequence filtering)
    if @job.Type =~ /^memsat/ || @job.Type =~ /^mempack/ || @job.Type =~ /^svmmemsat/
      params[:complex] = "false"
      params[:membrane] = "false"
      params[:coil] = "false"
    end

    @msa_found = 0 
    if(@job.QueryString.to_s.count('>') <= 1)
      #remove any FASTA description line that starts with a >
      @job.QueryString.gsub!(/^>.+\n/,"")
      #remove newlines or space characters from the incoming query sequence.
      # and upcase it
      #puts @job.QueryString
      #puts @job.QueryString.gsub(/\n|\s/, "")
      @job.QueryString = @job.QueryString.gsub(/\n|\s|\d/, "").upcase
    else
      @msa_found = 1
      input_msa = @job.QueryString.to_s
      lines = input_msa.split(/\n/)
      new_msa = String.new()
      #Here we rewrite the fasta headers so that the are all unique, blast+ will cat subsequent sequences with identical headers together
      #if the header lines are not unique. The alternative would be to bounce inputs that have identical sequences/headers but maybe someone
      #has a reason for listing the same sequence twice in their MSA.
      lines.each_with_index do |line,index|
        if(line =~ /^>/)
          line.gsub!( /^>.+/, ">sequence_"+index.to_s )
        end
        new_msa = new_msa + line + "\n"
      end
      @job.QueryString = new_msa
    end

    #this creates a global variable with the password value set so that the validate method in the job model can see it. Bit of
    #an ugly hack but I couldn't immediate see a better way to do it.
    $passwd = params[:passwd]
    logger.info("Jobs" + @job_count.to_s)
    #attempt to save, if some data is missing from the form, throw the form again with the appropriate warnings
    ip = @job.ip
    respond_to do |format|
      begin
        if(@msa_found == 1 && @job.Type =~ /^genthreader|^mempack|^svmmemsat/)
            @error_message = "MSA input not available for GenTHREADER. MSA input for Mempack or MEMSAT-SVM is not yet implemented."
            format.html { render :action => "error"}
        elsif(@job_count >= 10 && @job.user_id != 0)
            @error_message = "Your IP address, #{ip}, has 10 live jobs running.  Please wait until your jobs have finished before submitting more. "
            #@error_message = "Your email address, #{@job.address}, has 25 live jobs running.  Please wait until your jobs have finished before submitting more. "

          format.html { render :action => "error"}
        elsif(@job.user_id == 0 && @job_count >= 20)
            @error_message = "Your IP address, #{ip}, has 20 live jobs running.  Please wait until your jobs have finished before submitting more. "
            #@error_message = "Your email address, #{@job.address}, has 25 live jobs running.  Please wait until your jobs have finished before submitting more. "

          format.html { render :action => "error"}
        elsif(@job.user_id == 11)
          @error_message = "Your IP address, #{ip},  has been banned from submitting jobs due to misuse of our server. If you feel this is an error or you wish to restablish access please contact us."
            format.html { render :action => "error"}
        else

        @job.save!
        #create an object for each override settings.  Then save all the settings that will override the job defaults
        #kind of ugly. Is there a cleaner way to do this?
        complexOverride = JobConfigOverride.create()
        complexOverride.job_id = @job.id
        complexOverride.key = "complex_filter_setting"
        complexOverride.value = params[:complex]
        complexOverride.save!

        coilOverride = JobConfigOverride.create()
        coilOverride.job_id = @job.id
        coilOverride.key = "coil_filter_setting"
        coilOverride.value = params[:coil]
        coilOverride.save!

        membraneOverride = JobConfigOverride.create()
        membraneOverride.job_id = @job.id
        membraneOverride.key = "membrane_filter_setting"
        membraneOverride.value = params[:membrane]
        membraneOverride.save!

        resultOverride = JobConfigOverride.create()
        resultOverride.job_id = @job.id
        resultOverride.key = "result_filter_setting"
        resultOverride.value = "GUESS"
        resultOverride.save!

        gen_emailOverride = JobConfigOverride.create()
        gen_emailOverride.job_id = @job.id
        gen_emailOverride.key = "gen_email_setting"
        gen_emailOverride.value = params[:gen_email]
        gen_emailOverride.save!

        blastOverride = JobConfigOverride.create()
        blastOverride.job_id = @job.id
        blastOverride.key = "msa_control_setting"
        blastOverride.value = params[:msa_control]
        blastOverride.save!
        
        msaOverride = JobConfigOverride.create()
        msaOverride.job_id = @job.id
        msaOverride.key = "msa_input"
        msaOverride.value = @msa_found
        #msaOverride.value = 0
        msaOverride.save!

        #actually submit the job (expect and array of job objects as the function isn't overloaded)
        @job.submit_jobs([@job])

        #format output
        format.html
        #add line to throw XML for our upcoming webservice
        end
      rescue Exception => e
        format.html { render :action => "index"}
        #add line to throw XML for our upcoming webservice
      end
    end

    
  end

  def result
    @service_name = "psipredtest"

    #getting the data for the incoming job ID, the exception handling allows us to handle throwing an error view if the ID
    #is wrong
    begin
      @job = Job.find(params[:id])
      @job_results = @job.request_results.find(:all)
      
      #get any job config overrides parameters that the view might need to use
      @result_override = @job.job_config_overrides.find(:all, :conditions => "job_config_overrides.key = 'result_filter_setting'")
      @table_rows = {}
      @alignments = {}
      @result_filter = ''
      @result_override.each do |filter_state|
        @result_filter = filter_state.value
      end


      path =""
    #if a download path is available for this config/job get it from the configurations in the database
      curconfig = Configuration.find_by_name(@job.Type)
      if ((@job.Type !~ /BioSerf|ModifiedNewPred|FragFold/))
        override = curconfig.configuration_entries.find(:all, :conditions => "configuration_entries.key = 'DownloadPath'")
        path = ""
        override.each do |config|
          path = config.value
        end
      end

     # @file_results = @job.request_results.find(:all)
     # @file_results.each do |anno_state|
     #   if anno_state.status_class == 49
     #       if ! File.exist? path + anno_state.content_name
     #         fhAln = File.open(path + anno_state.content_name, 'w')
     #         fhAln.write( anno_state.data)
     #         fhAln.close
     #       end
     #   end
     # end
#
#      @file_results.each do |anno_state|
#        if anno_state.status_class == 48
#          if ! File.exist? path + anno_state.content_name
#              fhAnn = File.open(path + anno_state.content_name, 'w')
#              fhAnn.write( anno_state.data)
#              fhAnn.close
#
#          end
#        end
#      end


      #loop through the job states to find out what state the job finished in.  Did it complete?
      job_complete = 0
      if @job.state == 3
        job_complete = 2
        @error_message = "And internal server error has caused this job to fail"
      end
      
      @job_results.each do |job_state|
        if (job_state.status =~ /Job Complete/)
         job_complete = 1
        end
        if (job_state.status_class == 3)
          job_complete = 2
          @error_message = job_state.status
        end
        #if(job_state.status_class == 44)
        #  job_complete = 1
        #  break
        #end
       
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
    @service_name = "psipredtest"
  end

end
