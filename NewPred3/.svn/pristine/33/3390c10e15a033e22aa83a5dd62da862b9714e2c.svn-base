class Job < ActiveRecord::Base
  #acts_as_tree :foreign_key => "job_id", :order => :id
  
  require "pp"
  
  # Next line ensures output is not buffered - useful when redirecting runner daemon's output to a file!
  STDOUT.sync = true
  
  belongs_to  :job_configuration
  belongs_to  :user
  belongs_to  :server
  belongs_to  :ff_expansion
  has_many    :request_results, :dependent => :destroy
  has_many    :results, :as => :resultable
  has_and_belongs_to_many :pending_runs
  has_many    :test_models
  has_many :job_config_overrides, :dependent => :destroy

  #check how this interacts with metsite
  #validates_presence_of :QueryString, :message => "Sequence must not be blank", :if => :seq_required?
  validates :QueryString, :presence => {:message => 'Sequence must not be blank'}, :if => :seq_required?
  #validates_presence_of :address, :message => "You must provide an email address"
  #validates_presence_of :name, :message => "You must provide a short identifier for your sequence"
  validates :name, :presence => {:message => 'You must provide a short identifier for your sequence'}
  validates :Type, :presence => {:message => "A server type must be selected"}

  #validates_presence_of :address, :message => "You must provide an email address", :if => :email_required?
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Your email address does not look like a regular email address", :if => :address?
  #validates_reverse_format_of :QueryString, :with => /[^ACDEFGHIKLMNPQRSTVWY_-]+/i, :message => "Your sequence contain47s invalid characters"
  validates_with JobValidator

  scope :by_state_search, ( lambda do |state|
  		{:conditions => ['state = ?', state]}
	end)
	
	scope :by_state_and_address, (lambda do |state| 
  	{:conditions => ['state = ? AND address = ?', state,"servers@predictioncenter.org"]}
	end)
	
	scope :by_running_and_ip, (lambda do |ip|
    { :conditions => ["state <> 4 AND state <> 3 AND ip = ?",ip]}
  end )
  
  scope :by_uuid, (lambda do |id|
    { :conditions => ["UUID=?",id]}
  end )
  
  #count how many jobs a given IP currently has
  def self.countJobs(ip)
    count = 0
    running_jobs = self.by_running_and_ip(ip)
    running_jobs.each_with_index do |running, index|
      count = index+1
    end
    return count
  end


  def extend_by_job
    begin
      self.extend Kernel.const_get("#{Type}Mixin")
    rescue
      self.extend Kernel.const_get("GenericMixin")
    end
  end

  def email_required?
    self.Type =~ /BioSerf|psipred|genthreader|mgenthreader|domthreader|memsat|svmmemsat|dompred|disopred|metsite|hspred|ffpred|maketdb|seqJob|structJob/
  end

  def seq_required?
    self.Type !~ /SimpleModeller|structJob/
  end

  def self.poll_all_loop
    while (true)
      poll_all_status
      poll_all_resubmit
      sleep 15
    end
  end

  # checks for queued jobs needing submission
  def self.poll_all_resubmit
    jobs = Job.find(:all, :conditions => "state = 5")

    puts "Job Queue: #{jobs.length}"

    if (jobs.length > 0)
      jobs.first.submit_jobs(jobs)
    end
  end

  
  # simple function to check status on all non errored or completed jobs
  # First we look for jobs older than 24 hours and set them to state 3
  # first of all we test the the Rails app is connected to the mysql db
  def self.poll_all_status
    

    #we get all incomplete jobs older than 24 hours and set them to failed
    #and manually add a request result with a time out message
    jobs = Job.find(:all, :conditions => ["state <> 4 AND state <> 3 AND state <> 5 AND updated_at <= ?", 24.hours.ago] )
    for job in jobs
      job.state = 3
      job.save!
      
      timedoutstatus = RequestResult.create()
      timedoutstatus.job_id = job.id
      timedoutstatus.status_class = 3
      timedoutstatus.status = "This job timed out. Please try submitting your job again"
      timedoutstatus.content_type = "text/plain"
      #newstatus.content_name = job_status.status
      timedoutstatus.content_name = "Time out"
      timedoutstatus.data = "Time out"
      timedoutstatus.save!
      
      if (!job.address.nil?)
        JobMailer.error(job,"This job timed out. Please resubmit your job.").deliver
      end

      puts "job timed out: #{job.id}"
    end

    
    jobs = Job.find(:all, :conditions => "state <> 4 AND state <> 3 AND state <> 5" )
    #TODO: possibly sort out jobs that fail to get a server id where server id (and state) remain nulls
    puts "Jobs found : #{jobs.length}"
    for job in jobs
      job.poll_status
    end
  end
  
  def fix_string(input)
    return input.gsub(" ", "_")
  end

  def self.batch_destroy(start, final)
    start = start.to_i
    final = final.to_i

    for i in start...final do
      begin
        ent = Job.find(i)
      rescue Exception => e
        puts "Skipped nonexistent #{i}"
        next
      end
      if ((ent.state.to_i != 4) && (ent.state.to_i != 3))
        puts "Killing #{i}"
        begin
          ent.kill
        rescue
          puts "Failed to kill #{i}"
        end
      end
      puts "Destroying #{i}"
      ent.destroy
    end

  end

  def self.batch_store_to_tgz(start, final, tmpdir, output)
    require 'archive/tar/minitar'
    require 'zlib'

    dlset = Array.new
    start = start.to_i
    final = final.to_i

    for i in start...final do
      ent = Job.find(i)
      if (ent.state.to_i != 4)
        puts "Incomplete job #{ent.id} #{ent.name} #{ent.state}"
        next
      end
      dlset << ent
    end

    puts "Got #{dlset.length} jobs"

    tgz = File.new("#{tmpdir}/#{output}", "w+")
    tgz.close

    archives = Array.new
    for job in dlset
      temp_tgz = Tempfile.new("bs_tgz", tmpdir)
      temp_tgz.close(false)
      job.store_to_tgz(temp_tgz.path)
      archives << [job.name, temp_tgz]
    end

    Zlib::GzipWriter.open(tgz.path) do |gzip|
      Archive::Tar::Minitar::Output.open(gzip) do |out|
        # write the debug entries, filename by status field (with fixed spaces etc)
        for entry in archives
          out.tar().mkdir("#{entry.first}", :mode => 0755, :mtime => Time.now)
          source = File.open(entry.last.path, "rb")
          out.tar().add_file_simple("#{entry.first}/#{entry.first}_full.tgz", :mode => 0600,
            :size => source.stat.size, :mtime => Time.now) do |stream, io|
            stream.write(source.gets(nil))
          end
          source.close
        end
      end
    end

    # clean up the temporary tgz files
    for entry in archives
      entry.last.close(true)
    end

  end
    
  def store_to_tgz(tgz)
    return if (tgz.nil?)
    require 'archive/tar/minitar'
    require 'zlib'
    
    debug = self.request_results.find(:all, :conditions => "status_class = 4")
    puts "debug: #{debug.length}"
    final_models = self.request_results.find(:all, :conditions => "status_class = 6")
    puts "final: #{final_models.length}"
    alternate_models = self.request_results.find(:all, :conditions => "status_class = 7")
    puts "alternate: #{alternate_models.length}"
    
    Zlib::GzipWriter.open(tgz) do |gzip|
      Archive::Tar::Minitar::Output.open(gzip) do |out|
        # write the debug entries, filename by status field (with fixed spaces etc)
        if (debug.length > 0)
          out.tar().mkdir("debug", :mode => 0755, :mtime => Time.now)
          for ent in debug
            out.tar().add_file_simple("debug/#{fix_string(ent.status)}.txt", :mode => 0600, 
              :size => ent.data.length, :mtime => Time.now) do |stream, io|
              stream.write(ent.data)
            end
          end
        end
        # write the final models
        if (final_models.length > 0)
          out.tar().mkdir("final_models", :mode => 0755, :mtime => Time.now)
          i = 0
          for model in final_models
            out.tar().add_file_simple("final_models/#{self.name}_#{i}.pdb", :mode => 0600, 
              :size => model.data.length, :mtime => Time.now ) do |stream, io|
              stream.write(model.data)
              i = i + 1
            end
          end
        end
        
        # write the intermediate models
        if (alternate_models.length > 0)
          out.tar().mkdir("alternate_models", :mode => 0755, :mtime => Time.now)
          i = 0
          for model in alternate_models
            out.tar().add_file_simple("alternate_models/#{self.name}_#{i}.pdb", :mode => 0600, 
              :size => model.data.length, :mtime => Time.now) do |stream, io|
              stream.write(model.data)
              i = i + 1
            end
          end
        end
      end
    end
  end
  
  def kill
    unless self.server.nil?
      npc = self.server.get_connection
      npc.kill_job(self.id)
    end
    # let the status updates from the server handle the kill notifications
  end
  
  def model_count
    puts state
    return 0 if state != 4
    return request_results.count(:conditions => "status_class = 6")
  end
  
  def get_models
    get_result(6)
  end
  
  def get_result(class_id)
    return nil if self.state != 4
    models = nil
    for result in self.request_results.find(:all, :conditions => "status_class = #{class_id}")
      if (models.nil?)
        models = [ result.data ]
      else
        models << result.data
      end
    end
    return models
  end

  def get_alternate_models
    get_result(7)
  end
  
  # helper function to convert a pdb file to a casp formate model
  def convert_to_casp(model, id)
    # if in casp format already, just return it then...
    if (model.include? "PFRMAT")
      return model
    end
    
    casp = "PFRMAT TS\n"
    casp = "#{casp}TARGET #{name}\n"
    casp = "#{casp}AUTHOR BioSerf\n"
    casp = "#{casp}REMARK \n"
    casp = "#{casp}METHOD Template-based modelling with BLAST and mGenTHREADER and ab initio predictions by FRAGFOLD\n"
    casp = "#{casp}MODEL   #{id}  REFINED\n"
    casp = "#{casp}PARENT N/A\n"
    
    lines = model.split("\n")
    occ_fix = "1.00  0.00"
    occ_end = occ_fix.length + 56
    for line in lines
      if (line.include?("ATOM") || line.include?("HETATM"))
        casp = "#{casp}#{line.slice(0, 56)}#{occ_fix}#{line.slice(occ_end, line.length - occ_end)}\n"
      end
    end
    
    casp = "#{casp}TER\nEND\n"
    return casp
  end

  def poll_status
    # if job already complete, or errored return immediately
    return if (self.state == 4 || self.state == 3)

    #some malformatted input can lead to jobs ending up in state -1 (happens when you request to run a job type at the backend that doesn't exist)
    if self.state == -1
      self.state = 3
      self.save!
      JobMailer.error(self,"Your job has failed. Job type requested does not exist.").deliver
      JobMailer.statuserror(self, "-1").deliver
      
      return
    end

    #What to do if state is undef, which technically shouldn't happen but I've never been able to work out how it happens but it does
    if self.state.nil?
      self.state = 3
      self.save!
      JobMailer.error(self,"Job was not allocated to a server. Please resubmit if you have not already done so").deliver
      return
    end
    
    puts "polling Server #{self.server_id} for job #{self.id}"
    begin
      npc = self.server.get_connection
      job_status = npc.get_status(self.id)
    rescue Exception => e
      puts "Failed to get server connection"
      #Commented out next line to avoid flood of emails as this gets done every 20 seconds for each server...
      #JobMailer.serverfailure(self.server_id).deliver
      #TODO: This will only notify you that a server has gone if it goes away when the server has an active job.
      #If there are no active jobs a server won't be polled and you won't find out that it's crashed.

      #self.state = 3
      #self.save!
      #if self.address.length > 0
      #   JobNotifier.deliver_error(self,"Your job has failed due to an internal server error.")
      #end
      
      #TODO: set a job that it's server has gone away to state 3 and send email about it. Currently jobs that don't get their server set cause to
      #poll loop to hang so setting to 3 would get round that; but...
      #If for whatever reason a server takes so long (>15secs) to return results that the poll_all loop tries again
      #before the results are finished returning then it seems like the server won't allow a connection.
      return
    rescue Timeout::Error => e
      puts "Connection Timeout. Going to try again"
      self.state = 0
      self.save!
      return
    end
    puts "polling done"
    
    
    # poll the server for any status updates and add them to db
    @end_poll = false
    while (job_status && !@end_poll)

      
      #puts job_status
      newstatus = RequestResult.create()
      newstatus.job_id = self.id
      

      #if a download path is available for this config/job get it from the configurations in the database
      curconfig = JobConfiguration.find_by_name(self.Type)
      if ((self.Type !~ /BioSerf|ModifiedNewPred|FragFold/))
          override = curconfig.configuration_entries.find(:all, :conditions => "configuration_entries.key = 'DownloadPath'")
        path = ""
        override.each do |config|
          path = config.value
        end
      end

      #We are no longer emailing psiblat results because that is madneess
      psiblast_switch = "opnone"
      #for over in self.job_config_overrides.find(:all, :conditions => "job_config_overrides.key = 'psiblast_output_option'")
      #  psiblast_switch = over.value
      #end


      #here we verify the our mysql handles are all live; this is pretty non-ideal, quite and expensive operation EVERY time get data from the servers
      ActiveRecord::Base.verify_active_connections!
      begin
        #puts "About to handle status"
        JobStatusHandler.handle_status(job_status, newstatus, self, logger, path)
        #puts "About to email"
        EmailHandler.handle_email(job_status, newstatus, logger, psiblast_switch, path, self)
        #puts "Emailed yo"
        newstatus.save!

      rescue Exception=>e
        #Should we set status to 3 here?
        JobMailer.insertfailure(self.id,job_status.status_class,job_status.status+" "+e.to_s).deliver
      end

      job_status = npc.get_status(self.id)
    end
    
  end

  # used for increasing the model sample count
  def more_ff_resubmit
    override =  self.job_config_overrides.find(:all, :conditions => { :key => "FF_MAX_MODELS" })

    if override.length == 1
      override.value = 500
      override.save!
    else
      override = JobConfigOverride.new
      override.job_id = self.id
      override.key = "FF_MAX_MODELS"
      override.value = 500
      override.save!
    end

    self.resubmit
  end

  def resubmit
    newstatus = RequestResult.create()
    newstatus.job_id = self.id
    newstatus.status_class = 2 # treat a resubmit as flow back to start again
    newstatus.status = "Job Resubmitted at #{Time.now}"
    self.state = 0
    self.save!
    submit_jobs([self])
  end
  
  def submit_jobs(jobs)
    require 'yaml'
    
    skip_server = Hash.new(false)

    for job in jobs
      logger.info "Looking to submit job, id #{job.id}"
      
      # Queue job to server with shortest queue.
      server_id = -1
      server_jobcount = 0
      for temp_id in 0..job.job_configuration.servers.length-1
        next if skip_server[temp_id]
        temp_server = job.job_configuration.servers[temp_id]
        begin
          temp_npc = temp_server.get_connection
          temp_status = temp_npc.get_status(job.id)
        rescue Exception => e
          #Commented out next line to avoid flood of emails (this gets done every submitted job if failed server is the first one)
          #JobMailer.serverfailure(temp_id).deliver
          logger.info "Job id #{job.id} is testing client #{temp_npc} i.e. server number #{temp_id} but this server is DOWN and will be skipped!"
          next
        end
        jobcount = temp_npc.get_job_count()
        if server_id == -1 or jobcount < server_jobcount
          server_id = temp_id
          cur_server = temp_server
          npc = temp_npc
          server_jobcount = jobcount
        end
      end
      
      if server_id == -1
        if job.state != 5
          job.state = 5
          job.save!
        end
        next
      end
      
      logger.info cur_server
      job.server = cur_server
      logger.info "null server" if cur_server.nil?
      logger.info "Job id #{job.id} got client #{npc} i.e. server number #{server_id} - this had a queue of #{server_jobcount} job(s)"
      
      # TODO EDIT about what follows: note that this whole mechanism does not work properly (job state = 5 results in sporadic crashes of the runner)!
      # TODO note next line means that an existing server will always be sent at most the same number of jobs.
      #      Instead, we want to change this value dinamically even for servers we already have 
      #      (e.g. if we set PSIBLASTs to use 4 cores at a time!). How to do it, apart from the hard-coding solution?
      if server_jobcount >= cur_server.maxjobs
        # server is full. for now, set to unqueued state to resubmit later
        job.state = 5
        job.save!
        skip_server[server_id] = true
        next
      end
      
      additional_params = Hash.new
      additional_params.merge!("seqname" => job.name)
      
      # add any job specific configured overrides
      for override in job.job_config_overrides
        additional_params.merge!(override.key => override.value)
      end
      
      wireconfig = job.job_configuration.to_wire_format(additional_params)
	  
	  #logger.info "THIS IS THE CONFIG TO BE SENT"
      #logger.info pp wireconfig

      if job.user_id == 0
        logger.info "adding job: Job id #{job.id}"
        status = npc.add_job(job.id, job.Type ,2, job.QueryString.to_s, wireconfig)
      else
        logger.info "adding job: Job id #{job.id}"
        begin
          status = npc.add_job(job.id, job.Type ,job.user.user_class, job.QueryString.to_s, wireconfig)
        rescue
          logger.info "add job failed: Job id #{job.id}"
        end
      end
      logger.info "got status, #{status}, for Job id #{job.id}"

      if status
        logger.info "called addJob: Status #{status}"
      else
        logger.info "failed addjob"
      end

      job.state = status
      job.save!
    end
  end

  protected


end
