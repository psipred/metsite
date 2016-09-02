class PsipredController < ApplicationController

  include FfpredDataProcessor
  require "open3"
  include Open3
  require 'digest/md5'
  require 'rubygems'
  require 'uuidtools'
  require "unicode_utils/upcase"
  include ControllerTools

  def index
    setViewVars()
  end

  def test
    setViewVars()
  end

  def ongoing
    @service_name = "psipred"
  end

  def submit
    #TODO: sanity check all params in params[], sanityCheck()
    #AUTO FILL BLOCK ENDS
    @service_name = "psipred"# service name for the application layout header.

    #create a new job object
    @job = Job.new()

    #Assign the basic job information from the input form
    @job.QueryString = params[:sequence]
    @job.QueryString.gsub!(/\r/,"")
    @job.address = params[:email]
    @job.name = params[:subject]
    @job.name = @job.name.gsub(/\s/,"_")
    @job.Type = "seqJob"
    @job.UUID  = UUIDTools::UUID.timestamp_create().to_s
    setViewVars()
    #Here we send which jobs we're running to the jobs table
    #Down below we'll also pass these as job_overrides, a little inelegant but the process already exists for passing arbitrary values the backend

    #OK initialise these to our defaults before testing what the website has set or what someone's REST attempt thinks it is passing.
    @job.program_psipred = 1
    @job.program_disopred = 0
    @job.program_mgenthreader = 0
    @job.program_svmmemsat = 0
    @job.program_bioserf = 0
    @job.program_dompred = 0
    @job.program_ffpred = 0
    @job.program_genthreader = 0
    @job.program_mempack = 0
    @job.program_domthreader = 0
    @job.program_domserf = 0

    #Now examine what is being passed in from the form or as REST request and set the job type
    @job.program_psipred = jobCheck(params[:program_psipred])
    @job.program_disopred = jobCheck(params[:program_disopred])
    @job.program_mgenthreader =jobCheck(params[:program_mgenthreader])
    @job.program_svmmemsat = jobCheck(params[:program_svmmemsat])
    @job.program_bioserf = jobCheck(params[:program_bioserf])
    @job.program_dompred = jobCheck(params[:program_dompred])
    @job.program_ffpred = jobCheck(params[:program_ffpred])
    @job.program_genthreader = jobCheck(params[:program_genthreader])
    @job.program_mempack = jobCheck(params[:program_mempack])
    @job.program_domthreader = jobCheck(params[:program_domthreader])
    @job.program_domserf = jobCheck(params[:program_domserf])

    overrideInputs()
    @job.ip = setIP()

    #Test the MODELLER key is valid if a BioSerf job has been requested
    @model_test=1
    if(@job.program_bioserf== 1 || @job.program_domserf == 1)
      @model_test=testModellerKey(@mod_key)
    end

    #Set the user ID
    @job.user_id = setUID(@job.address)

    #for abusers or regular users we take a job count
    job_count = Job.countJobs(@job.ip)

    #set the current configuration options which we will pass to the backend
    curconfig = JobConfiguration.find_by_name(@job.Type)
    @job.job_configuration_id = curconfig.id

    #test to see if the input is an MSA
    @msa_found = 0
    @msa_found = processMSA()

    #this creates a global variable with the password value set so that the validate method in the job model can see it. Bit of
    #an ugly hack but I couldn't immediate see a better way to do it.
    $passwd = params[:passwd]
    logger.info("Jobs" + job_count.to_s)
    #attempt to save, if some data is missing from the form, throw the form again with the appropriate warnings
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

          logger.info("#{@job.id}")
          #create an object for each override settings.  Then save all the settings that will override the job defaults
          #kind of ugly. Is there a cleaner way to do this?
          #4 years later and I still can't think of a more elegant way of doing this. I suspect the issue is that the whole
          #shebang would need redoing.
          assignOverrides()

          #Here we check the cache for a psiblast checkpoint file
          assignCacheOverrides()
          
          #actually submit the job (expect and array of job objects as the function isn't overloaded)
          @job.submit_jobs([@job])

          #format output
          #format.html { render :action => "error"}
          format.html
          #add line to throw XML for our upcoming webservice
          
        end
      rescue Exception => e
      #format.html { render :action => "error"}
        logger.info(e.to_s)
        format.html { render :action => "index"}
      #add line to throw XML for our upcoming webservice
      end
    end

  end

  def result
    @service_name = "psipred"

    #getting the data for the incoming job ID, the exception handling allows us to handle throwing an error view if the ID
    #is wrong
    begin
    #@job = Job.find(params[:id])
      @genome3d = 0
      id = params[:id]
      @job_tmp = Job.by_uuid(id)
      @job = @job_tmp[0]
      #This is the array of results
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
      
      #TODO: Move this chunk to a function in FFpredDataProcessor library
      @hOBJ = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
      #do the ffpred data processing
      if(job_complete == 1)

        if @job.program_ffpred == 1
          @job_results.each do |job_state|
            if(job_state.status_class == 38)
              @hOBJ = get_data(@hOBJ, job_state)
            end
            if(job_state.status_class == 37)
              @hOBJ["PREDSTRICT"] = get_go(job_state)
            end
            if(job_state.status_class == 88)
              @hOBJ["PREDFULL"] = get_go(job_state)
            end
          end
          @Thingy = 'OH NO'
          @hOBJ = get_aa_order(@hOBJ)
          @hOBJ = get_cats(@hOBJ)
        end
        ####

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

  def processMSA
    if(@job.QueryString.to_s.count('>') <= 1)
      #remove any FASTA description line that starts with a >
      @job.QueryString.gsub!(/^>.+\n/,"")
      #remove newlines or space characters from the incoming query sequence.
      # and upcase it
      #puts @job.QueryString
      #puts @job.QueryString.gsub(/\n|\s/, "")
      @job.QueryString = @job.QueryString.gsub(/\n|\s|\d/, "").upcase
      @job.QueryString = UnicodeUtils.upcase(@job.QueryString)
    return 0
    else
      input_msa = @job.QueryString.to_s
      lines = input_msa.split(/\n/)

      new_msa = String.new()
      #Here we rewrite the fasta headers so that the are all unique, blast+ will cat subsequent sequences with identical headers together
      #if the header lines are not unique. The alternative would be to bounce inputs that have identical sequences/headers but maybe someone
      #has a reason for listing the same sequence twice in their MSA.

      lines.each_with_index do | line, index |
        if(line =~ /^>/)
          line.gsub!( /^>.*/, ">sequence_"+index.to_s )
        else
          line.gsub!(/\n|\s|\d/, "")
          line = UnicodeUtils.upcase(line)
        end

        new_msa = new_msa + line + "\n"
      end
    @job.QueryString = new_msa
    return 1
    end
  end

  def assignCacheOverrides
    #take an md5 of the sequence
    seq = @job.QueryString
    md5 = Digest::MD5.hexdigest(seq)

    #check if it exists in the backend DB.
    cache = CheckPointCache.find(:all, :conditions => ["MD5 = ?", md5])
    #if so send it to the backend as an override

    cache.each do |cache_data|
      overrider(cache_data.chk_type,cache_data.data)
      #increment the usage by 1
      cache_data.usages+=1
      cache_data.save!
    end

  end

  #check what the incoming jobtype parameter is and also reject non-valid strings/values
  def jobCheck(parameter)

    if(! defined?(parameter) || parameter.nil?)
    return 0
    else
      if parameter.to_i == 1
      return 1
      else
      return 0
      end
    end

  end

  #rather dull function that works through all the form elements and adds them a job config overrides
  #create an object for each override settings.  Then save all the settings that will override the job defaults
  #kind of ugly. Is there a cleaner way to do this?
  #4 years later and I still can't think of a more elegant way of doing this. I suspect the issue is that the whole
  #shebang would need redoing.
  #Note: This is all messaging for the backend
  def assignOverrides
    overrider("program_psipred",@job.program_psipred)
    overrider("program_disopred",@job.program_disopred)
    overrider("program_mgenthreader",@job.program_mgenthreader)
    overrider("program_svmmemsat",@job.program_svmmemsat)
    overrider("program_mempack",@job.program_mempack)
    overrider("program_bioserf",@job.program_bioserf)
    overrider("program_dompred",@job.program_dompred)
    overrider("program_ffpred",@job.program_ffpred)
    overrider("program_genthreader",@job.program_genthreader)
    overrider("program_domthreader",@job.program_domthreader)
    overrider("program_domserf",@job.program_domserf)

    #Sequence filter overrides
    overrider("complex_filter_setting",params[:complex])
    overrider("coil_filter_setting",params[:coil])
    overrider("membrane_filter_setting",params[:membrane])

    #genthreader settings
    overrider("result_filter_setting","GUESS")

    #BioSerf genthreader override
    overrider("TS_MGT_MIN_MIN_SCORE",35)

    #msa settings
    overrider("msa_control_setting", params[:msa_control] )
    overrider("msa_input",@msa_found)

    #disopred overrides
    if ! params[:falseRate].nil?
      overrider("diso_false_positive_setting", params[:falseRate])
    end
    if ! params[:secStructPred].nil?
      overrider("secondary_structure_prediction", params[:secStructPred])
    end
    if ! params[:output].nil?
      overrider("psiblast_output_option", params[:output])
    end

    #dompred overrides
    if ! params[:iterations].nil?
      overrider("psi_blast_iterations", params[:iterations])
    else
      overrider("psi_blast_iterations", 5)
    end
    if ! params[:seqalign].nil?
      overrider("perform_psiblast", params[:seqalign])
    end

    if ! params[:database].nil?
      overrider("database", params[:database])
    end

    if ! params[:eval].nil?
      overrider("e_value", params[:eval])
    end

    if !  params[:domssea].nil?
      overrider("perform_domssea", params[:domssea])
    end

    if ! params[:secpro].nil?
      overrider("include_sec_structure_plot", params[:secpro])
    end

    if ! params[:pp].nil?
      overrider("display_psipred", params[:pp])
    end

  end

  #Work our what user ID the job should run with at the backend
  def setUID(email)

    # Ban users here
    #if (@job.ip =~ /^128\.255\.89\.157$/)
    #  return 11
    #end
    
    # OLD MATERIAL HERE:
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

  def image
    @service_name = "psipred"
    @imgid = params[:imageid]
  end

  def buildzip

    #get all the results for the job
    @job = Job.find(params[:id])
    @job_results = @job.request_results.find(:all)

    #name our zip file and build a tempfile
    file_name = "downloads.zip"
    t = Tempfile.new("my-temp-filename-#{@job.UUID}")

    #now we got through all our output types and stick them in our zip
    Zip::ZipOutputStream.open(t.path) do |z|

    #we loop through the results IDs for things that should be downloaded
    #TODO: could add the codes for all the images too.
      @job_results.each do |job_state|
        if( job_state.status_class == 11 ||
        job_state.status_class == 12 ||
        job_state.status_class == 13 ||
        job_state.status_class == 15 ||
        job_state.status_class == 24 ||
        job_state.status_class == 25 ||
        job_state.status_class == 27 ||
        job_state.status_class == 29 ||
        job_state.status_class == 9 ||
        job_state.status_class == 54 ||
        job_state.status_class == 55 ||
        job_state.status_class == 50 ||
        job_state.status_class == 56 ||
        job_state.status_class == 11 ||
        job_state.status_class == 16 ||
        job_state.status_class == 19 ||
        job_state.status_class == 6 ||
        job_state.status_class == 87 ||
        job_state.status_class == 90 ||
        job_state.status_class == 77 ||
        job_state.status_class == 81 ||
        job_state.status_class == 82 ||
        job_state.status_class == 80 ||
        job_state.status_class == 83 ||
        job_state.status_class == 51 ||
        job_state.status_class == 45 ||
        job_state.status_class == 46 ||
        job_state.status_class == 47 ||
        job_state.status_class == 10 ||
        job_state.status_class == 95 ||
        job_state.status_class == 96 ||
        job_state.status_class == 97 ||
        job_state.status_class == 101
        )

          title = job_state.content_name
          title.gsub!(/\/.+\//,"") #removing any preceeding path info that might have ended up in the name from the backend (this shouldn't happen now)
          if title =~ /No Contacts/
          next
          end
        z.put_next_entry(title)
        z.print job_state.data
        end
      end

    end
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
    t.close

  end

  def setViewVars
    @service_name = "psipred"# service name for the application layout header
    #This block allow external links to auto fill some features.
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

    @domserf = params[:domserf]
    if @domserf.nil?
      @domserf=''
    else
      @psipred=''
    end

    @ffpred = params[:ffpred]
    if @ffpred.nil?
      @ffpred=''
    else
      @psipred=''
    end

    @disopred = params[:disopred]
    if @disopred.nil?
      @disopred=''
    else
      @psipred=''
    end

    @pgenth = params[:pgenthreader]
    if @pgenth.nil?
      @pgenth=''
    else
      @psipred=''
    end

    @memsat = params[:memsatsvm]
    if @memsat.nil?
      @memsat=''
    else
      @psipred=''
    end

    @bioserf = params[:bioserf]
    if @bioserf.nil?
      @bioserf=''
    else
      @psipred=''
    end

    @dompred = params[:dompred]
    if @dompred.nil?
      @dompred=''
    else
      @psipred=''
    end

    @genth = params[:genthreader]
    if @genth.nil?
      @genth=''
    else
      @psipred=''
    end

    @mempack = params[:mempack]
    if @mempack.nil?
      @mempack=''
    else
      @psipred=''
    end

    @pdomth = params[:pdomthreader]
    if @pdomth.nil?
      @pdomth=''
    else
      @psipred=''
    end

    @psipred = params[:psipred]
    if @psipred.nil?
      @psipred=''
    end

    if @psipred.length == 0 && @ffpred.length == 0 && @disopred.length == 0 && @pgenth.length == 0 && @memsat.length == 0 && @bioserf.length == 0 && @dompred.length == 0 && @genth.length == 0 && @mempack.length == 0 && @pdomth.length == 0 && @domserf.length == 0
      @psipred=1.to_s
    end

  end

  def overrideInputs
    #if for some reason the user has deselected everything AND we get here  then set it to run a default psipred job.
    if(@job.program_psipred == 0 && @job.program_disopred == 0 && @job.program_mgenthreader == 0 && @job.program_svmmemsat == 0 && @job.program_bioserf == 0 && @job.program_dompred == 0 && @job.program_ffpred == 0 && @job.program_genthreader == 0 && @job.program_mempack == 0 && @job.program_domthreader == 0 && @job.program_domserf == 0)
    @job.program_psipred = 1
    end

    #override some options depending on which settings are set to true, because some jobs imply other jobs
    if(@job.program_mgenthreader == 1 || @job.program_dompred == 1 || @job.program_domthreader == 1)
    @job.program_psipred = 1
    end
    #if(@job.program_disopred == 1 && (params[:secStructPred] =~ /true/ || params[:secStructPred].nil?))
    if(@job.program_disopred == 1)
        @job.program_psipred = 1
    end
    if(@job.program_bioserf == 1)
    @job.program_psipred = 1
    @job.program_mgenthreader = 1
    end
    if(@job.program_ffpred == 1)
    @job.program_psipred = 1
    @job.program_disopred = 1
    #@job.program_dompred = 1
    @job.program_svmmemsat = 1
    end
    if(@job.program_domserf == 1)
    @job.program_psipred = 1
    @job.program_domthreader = 1
    end

    if(@job.program_mempack == 1)
    #mempack does a full memsat run anyway so no need to run this twice
    @job.program_svmmemsat == 0
    end

    if(@job.program_mgenthreader == 1 || @job.program_domthreader == 1)
    #don't run a genthreader job if mgen or domgen are running
    @job.program_genthreader == 0
    end
  end

end
