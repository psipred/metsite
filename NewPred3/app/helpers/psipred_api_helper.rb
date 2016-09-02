  module PsipredApiHelper

  require 'uuidtools'
  
  #Set the standard input variables querystring, name, type etc...
  def setStandardJobSettings(sequence, email, name)
    #file_data = sequence
    ##file data here is a File object
    #file_string = ""
    #file_data.each do |line|
    #  file_string = "#{file_string}#{line}"
    #end
    @job.QueryString = sequence

    #remove any FASTA description line that starts with a >
    #@job.QueryString.gsub!(/^>.+\n/,"")
    #@job.QueryString.gsub!(/\n|\s/, "")
    #remove number characters
    #@job.QueryString.gsub!(/\d/,"")
    @job.address = email
    @job.name = name

    @job.Type = "seqJob"

    #set the current configurations
    curconfig = JobConfiguration.find_by_name(@job.Type)
    @job.job_configuration_id = curconfig.id

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
    end

    @job.UUID  = UUIDTools::UUID.timestamp_create().to_s
    
  end

  #could refactor this a little with the other set standard settings method
  def setStandardStructSettings(pdb_file, email, name)
    #file_data = pdb_file
    #file data here is a File object
    #file_string = ""
    #file_data.each do |line|
    #  file_string = "#{file_string}#{line}"
    #end
    #@job.QueryString = file_string
	@job.QueryString = pdb_file

    #remove any FASTA description line that starts with a >
    #@job.QueryString.gsub!(/^>.+\n/,"")
    #@job.QueryString.gsub!(/\n|\s/, "")
    #remove number characters
    #@job.QueryString.gsub!(/\d/,"")
    @job.address = email
    @job.name = name

    @job.Type = "structJob"

    #set the current configurations
    curconfig = JobConfiguration.find_by_name(@job.Type)
    @job.job_configuration_id = curconfig.id
    
	@job.UUID  = UUIDTools::UUID.timestamp_create().to_s
	
  end

  #override some job settings to ensure all parents jobs runs
  def setAdditionalJobs

    #override some options depending on which settings are set to true
    if(@job.program_mgenthreader == 1 || @job.program_dompred == 1 || @job.program_domthreader == 1)
      @job.program_psipred = 1
    end
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
      @job.program_dompred = 1
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
    #svmmemsat,mempack,genthreader,mgenthreader,domthreader
    #@job.ip = request.remote_ip
  end

  def setUserID
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
        elsif @job.address =~ /hline\.org|ijmr\.in/
          #set to abusers ID: run priority 1
          @job.user_id = 8
          ip = @job.ip
          running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs.each_with_index do |running, index|
            job_count = index
          end
        else
          #Run at default run level: priority 2
          @job.user_id = 0
          ip = @job.ip
          running_jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND ip = '#{ip}'")
          running_jobs.each_with_index do |running, index|
            job_count = index
          end
        end

      #END set user
  end

    #rather dull function that works through all the form elements and adds them a job config overrides
  #create an object for each override settings.  Then save all the settings that will override the job defaults
  #kind of ugly. Is there a cleaner way to do this?
  #4 years later and I still can't think of a more elegant way of doing this. I suspect the issue is that the whole
  #shebang would need doing.
  def assignProgramOverrides
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


  end
