class BioSerfController < ApplicationController
  #include AuthenticatedSystem
  #before_filter :login_required, :except => [:public_result, :public_submission, :public_job, :getresultattached,:getresultattachedgenome3d]
  
  require "open3"
  include Open3
  require "unicode_utils/upcase"

  def index
    queue
    render :action => 'queue'
  end
  
  def newjob
  end

  def do_add_model
    @job = Job.find(params[:id])
    casp = @job.convert_to_casp(params[:model].gets(nil), params[:model_index])
    puts casp

    # note: this part need to be kept up to synch with changes in job.poll_status
    newstatus = RequestResult.create()
    newstatus.job_id = @job.id
    
    newstatus.status_class = 6
    newstatus.status = "pdb file result"
    newstatus.content_type = "application/octet-stream"
    newstatus.content_name = "#{@job.id}_#{params[:model_index]}.pdb"
    newstatus.data = casp
    
    newstatus.save!
        
    if (!@job.address.nil?)
      JobMailer.completion(@job, casp).deliver
    end
    
    redirect_to :action => 'status', :id => params[:id]
  end
  
  def add_model
    @job = Job.find(params[:id])
    
  end
  
  def getresultattached
    @job_result = RequestResult.find(params[:id])
    send_data( @job_result.data,
      :filename => @job_result.content_name,
      :type => @job_result.content_type,
      :disposition => "attachment")
  end
  
  def getresultattachedgenome3d
    @job_result = Genome3d.find(params[:id])
    send_data( @job_result.data,
      :filename => @job_result.content_name,
      :type => @job_result.content_type,
      :disposition => "attachment")
  end
  
  def getresultinline
    @job_result = RequestResult.find(params[:id])
    send_data( @job_result.data,
      :filename => @job_result.content_name,
      :type => @job_result.content_type,
      :disposition => "inline")
  end

  def getthumbnail
    @thumbnail = Thumbnail.find(params[:id])
    send_data(@thumbnail.data,
    :filename => @thumbnail.request_result.content_name,
    :type => @thumbnail.request_result.content_type,
    :disposition => "inline")
  end
  
  def download_job
    @job = Job.find(params[:id])
    tgz = Tempfile.new("bs_tgz")
    tgz.close(false)
    @job.store_to_tgz(tgz.path)
    send_file( tgz.path, :filename => "#{@job.name}_full.tgz", 
      :disposition => "attachment")
    #tgz.unlink
  end
      
  def full_status
    @job = Job.find(params[:id])
    @job_results = @job.request_results.collect
  end
  
  def status
    @job = Job.find(params[:id])
    @overrides = @job.job_config_overrides
    @job_results = @job.request_results.find(:all, :conditions => "status_class <> 7")
  end

  def public_status
    @job = Job.find(params[:id])
    @overrides = @job.job_config_overrides
    @job_results = @job.request_results.find(:all, :conditions => "status_class <> 7")
  end
  
  def kill_job
    @job = Job.find(params[:id])
    @job.kill
    redirect_to :action => 'status', :id => params[:id]
  end

  def do_regexdl
    require 'archive/tar/minitar'
    require 'zlib'

    dlset = Job.find(:all, :conditions => ["name LIKE ?", params[:filter]])
    puts "Query: #{params[:filter]}, #{dlset.length}"

    tgz = Tempfile.new("bs_tgz")
    tgz.close(false)

    archives = Array.new
    for job in dlset
      temp_tgz = Tempfile.new("bs_tgz")
      #temp_tgz.close(false)
      job.store_to_tgz(temp_tgz.path)
      archives << [job.name, temp_tgz]
	  temp_tgz.close(false)
    end

    Zlib::GzipWriter.open(tgz.path) do |gzip|
      Archive::Tar::Minitar::Output.open(gzip) do |out|
        # write the debug entries, filename by status field (with fixed spaces etc)
        for entry in archives
          out.tar().mkdir("#{entry.first}", :mode => 0755, :mtime => Time.now)
          out.tar().add_file_simple("#{entry.first}/#{entry.first}_full.tgz", :mode => 0600,
            :size => entry.last.length, :mtime => Time.now) do |stream, io|
            stream.write(entry.last.gets(nil))
          end
        end
      end
    end

    # clean up the temporary tgz files
    for entry in archives
      entry.last.close(true)
    end



    send_file( tgz.path, :filename => "batch_dl_full.tgz",
      :disposition => "attachment")
  end
  
  def batchdl_numeric_submit
    require 'archive/tar/minitar'
    require 'zlib'
    
    dlset = Array.new  
    start = params[:start_id].to_i
    final = params[:end_id].to_i

    for i in start...final do
      ent = Job.find(i)
      if (ent.state.to_i != 4)
        puts "Incomplete job #{ent.id} #{ent.name} #{ent.state}"
        next
      end
      dlset << ent
    end

    puts "Got #{dlset.length} jobs"
     
    tgz = Tempfile.new("bs_tgz")
    tgz.close(false)
    
    archives = Array.new
    for job in dlset
      temp_tgz = Tempfile.new("bs_tgz")
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
    
    
    
    send_file( tgz.path, :filename => "batch_dl_full.tgz", 
      :disposition => "attachment")
  end

  def batch_dl_jobs
    require 'archive/tar/minitar'
    require 'zlib'
    
    dlset = Array.new  
    params.each_pair do |name, checked|
      # skip form options and just get checkbox fields
      # could also salt checkboxes with some regex name to differentiate...
      if (name == 'action' || name == 'controller' || name == 'commit')
        next
      end
      dlset << Job.find(name) if checked
    end
    tgz = Tempfile.new("bs_tgz")
    tgz.close(false)
    
    archives = Array.new
    for job in dlset
      temp_tgz = Tempfile.new("bs_tgz")
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
    
    
    
    send_file( tgz.path, :filename => "batch_dl_full.tgz", 
      :disposition => "attachment")
  end
  
  def batchdl
    @page = params[:page]
    @jobs = Job.paginate :order => "created_at DESC", :page => @page, :per_page => 150
  end
  
  def batchkill
    @page = params[:page]
    @jobs = Job.by_state_search(0).paginate :order => "created_at DESC", :page => @page, :per_page => 150
  
  end

  def batch_kill_jobs
    params.each_pair do |name, checked|
      if (name == 'action' || name == 'controller' || name == 'commit')
        next
      end
      Job.find(name).kill if checked
    end
    redirect_to :action => 'index'
  end
  
  def batchresubmit
    @page = params[:page]
    #@jobs = Job.paginate_by_state 3, :order => "created_at DESC", :page => @page, :per_page => 150
  	@jobs = Job.by_state_search(3).paginate :order => "created_at DESC", :page => @page, :per_page => 150
  end
  
  def batch_resubmit_jobs
    params.each_pair do |name, checked|
      next if (name == 'action' || name == 'controller' || name == 'commit')
      Job.find(name).resubmit if checked
    end
    redirect_to :action => 'index'
  end
  
  def queue
    
    # Note: security risk to allow SQL in like this...
    @jobs_by = params[:order_by]
    @jobs_by = "created_at DESC" if @jobs_by.nil?
    @page = params[:page]
    
    @jobs = Job.paginate :order => @jobs_by, :page => @page, :per_page => 15
  end

  def casp_summary
    #@jobs = Job.paginate_by_state_and_address(4, "servers@predictioncenter.org", :order => "created_at DESC", :page => params[:page], :per_page => 10)
  	@jobs = Job.by_state_and_address(4).paginate :order => "created_at DESC", :page => @page, :per_page => 150
  
  end
  
  def ff_rand_submit
    sequences = params[:sequence].split("\n")

    if (logged_in?)
      uid = self.current_user.id
    else
      uid = 0
    end

    override_count = params[:ff_overrides].split("\n").length
    min_value = params[:param_min].to_f
    max_value = params[:param_max].to_f
    range = max_value - min_value
    sample_count = params[:sample_count].to_i

    logger.info("rand_job params min: #{min_value} max: #{max_value} range #{range} count #{sample_count}")
    valueset = Array.new
    (0...sample_count).each do |i|
      vals = Array.new
      (0...override_count).each do
        vals << ((rand(0) * range) + min_value).to_s
      end
      valueset << vals.join(",")
    end

    expansion = FfExpansion.new
    expansion.overrides = params[:ff_overrides].delete("\r").split("\n").join("\n")
    expansion.values = valueset.join("\n")

    expansion.save!
    jobset = Array.new

    sequences.each_with_index { |sequence, i|
      job = Job.create(:QueryString =>sequence, :Type => "BioSerf", :user_id => uid, :configuration_id => params[:newjob][:configuration_id],
        :address => nil, :ip => request.remote_ip, :name =>
          "#{params[:name]}-#{i.to_s.rjust(4, "0")}_ref", :ff_expansion_id => expansion.id)
      jobset << job
    }
    jobset.first.submit_jobs(jobset) if !jobset.empty?

    redirect_to :action => 'index'
  end

  def ff_submit
    @job = Job.new()
    @job.QueryString = params[:seq]
    @job.address = params[:address]
    @job.name = params[:name]
    @job.Type = "BioSerf"
    @job.user_id = 0

    #curconfig = Configuration.find_by_active(true)
    curconfig = Configuration.find_by_name("FF_Demo")
    if (curconfig)
      @job.configuration_id = curconfig.id
    else
      @job.configuration_id = 5
    end    

    @job.ip = request.remote_ip
    
    @job.save!
    
    JobMailer.casp_request(@job).deliver
    
    @job.submit_jobs([@job])
    
    redirect_to :action => 'index'
  end

  def casp10submit_ts
    @job = Job.new()
    @job.QueryString = params[:seq]
    @job.address = params[:address]
    @job.name = params[:name]
    @job.Type = "NewPred"
    @job.user_id = 0

    #curconfig = Configuration.find_by_active(true)
    curconfig = Configuration.find_by_name("NewPred")
    #curconfig = Configuration.find_by_name("Default bio_serf")
    if (curconfig)
      @job.configuration_id = curconfig.id
    else
      @job.configuration_id = 11
      #@job.configuration_id = 1
    end

    @job.ip = request.remote_ip

    @job.save!

    JobMailer.casp_request(@job).deliver

    @job.submit_jobs([@job])

    queue
    redirect_to :action => 'queue'

  end

  def casp10submit_fn
    @job = Job.new()
    @job.QueryString = params[:seq]
    @job.address = params[:address]
    @job.name = params[:name]
    @job.Type = "GenJobFN"
    @job.user_id = 0

    @job.QueryString = @job.QueryString.gsub(/\n|\s|\d/, "")
    @job.QueryString = UnicodeUtils.upcase(@job.QueryString)
    #curconfig = Configuration.find_by_active(true)
    curconfig = Configuration.find_by_name("GenJobFN")
    #curconfig = Configuration.find_by_name("Default bio_serf")
    if (curconfig)
      @job.configuration_id = curconfig.id
    else
      @job.configuration_id = 11
      #@job.configuration_id = 1
    end

    @job.ip = request.remote_ip

    @job.save!

    JobMailer.casp_request(@job).deliver

    @job.submit_jobs([@job])

    queue
    redirect_to :action => 'queue'

  end

  def casp9submit_ts
    @job = Job.new()
    @job.QueryString = params[:seq]
    @job.address = params[:address]
    @job.name = params[:name]
    @job.Type = "BioSerf"
    @job.user_id = 0

    #curconfig = Configuration.find_by_active(true)
    curconfig = Configuration.find_by_name("CASP 9 Default")
    if (curconfig)
      @job.configuration_id = curconfig.id
    else
      @job.configuration_id = 11
    end

    @job.ip = request.remote_ip

    @job.save!

    JobMailer.casp_request(@job).deliver

    @job.submit_jobs([@job])

    redirect_to :action => 'index'

  end

  
  
  def casp8submit_ts
    @job = Job.new()
    @job.QueryString = params[:seq]
    @job.address = params[:address]
    @job.name = params[:name]
    @job.Type = "BioSerf"
    @job.user_id = 0

    #curconfig = Configuration.find_by_active(true)
    curconfig = Configuration.find_by_name("CASP Default")
    if (curconfig)
      @job.configuration_id = curconfig.id
    else
      @job.configuration_id = 11
    end    

    @job.ip = request.remote_ip
    
    @job.save!
    
    JobMailer.casp_request(@job).deliver
    
    @job.submit_jobs([@job])
    
    redirect_to :action => 'queue'
  end

  def more_ff
    @job = Job.find(params[:id])
    @job.more_ff_resubmit
    redirect_to :action => 'status', :id => params[:id]
  end

  def resubmit
    @job = Job.find(params[:id])
    @job.resubmit
    redirect_to :action => 'status', :id => params[:id]
  end
  
  def paramsubmit
    sequences = params[:sequence]
    names = Array.new

    if (params.has_key? :param_name_1)
      names << params[:param_name_1]
      p1_ents = params[:param_entries_1].split(",")
    end

    if (params.has_key? :param_name_2)
      names << params[:param_name_2]
      p2_ents = params[:param_entries_2].split(",")
    end

    if (params.has_key? :param_name_3)
      names << params[:param_name_3]
      p3_ents = params[:param_entries_3].split(",")

    end
    if (params.has_key? :param_name_4)
      names << params[:param_name_4]
      p4_ents = params[:param_entries_4].split(",")
    end


    
    jobs = Array.new()
    sequences.each_with_index { |sequence, i|

      for p1_ent in p1_ents do

        for p2_ent in p2_ents do
          for p3_ent in p3_ents do
            for p4_ent in p4_ents do
              # log the submitting user... TODO add priority here too
              if (logged_in?)
                uid = self.current_user.id
              else
                uid = 0
              end
              # change in validation requires all fields to exist now...
              job = Job.create(:QueryString =>sequence, :Type => params[:job_type], :user_id => uid, :configuration_id => params[:newjob][:configuration_id],
                :address => nil, :ip => request.remote_ip, :name =>
                  "#{params[:name]}-#{i.to_s.rjust(4, "0")}_#{p1_ent}_#{p2_ent}_#{p3_ent}_#{p4_ent}")

              override1 = JobConfigOverride.create()

              override1.job_id = job.id
              override1.key = names.at(0)
              override1.value = p1_ent
              override1.save!
              override2 = JobConfigOverride.create()
              override2.job_id = job.id
              override2.key = names.at(1)
              override2.value = p2_ent
              override2.save!
              override3 = JobConfigOverride.create()
              override3.job_id = job.id
              override3.key = names.at(2)
              override3.value = p3_ent
              override3.save!
              override4 = JobConfigOverride.create()
              override4.job_id = job.id
              override4.key = names.at(3)
              override4.value = p4_ent
              override4.save!

              if !job.save
                flash[:error] = 'There was a problem.'
                redirect_to :action => 'status'
                return
              end
              jobs << job
            end
          end
        end
      end
    }
    
    jobs.first.submit_jobs(jobs) if !jobs.empty?
    
    redirect_to :action => 'index'
    return
  end
  
  def batchsubmit
    sequences = params[:sequence].split("\n")
    jobs = Array.new()
    
    sequences.each_with_index do |seq, i|
      job = Job.new()
      job.QueryString = seq
      job.Type = params[:job_type]
      job.name = "#{params[:name]}_#{i.to_s.rjust(4, "0")}"
      
      # log the submitting user... TODO add priority here too
      if (logged_in?)
        job.user_id = self.current_user.id
      else
        job.user_id = 0
      end
      
      # set config from drop down selection
      job.configuration_id = params[:newjob][:configuration_id]
      
      job.ip = request.remote_ip
      #@job.address = "S.Ward@cs.ucl.ac.uk"
      job.address = nil

      job.save!
      #if !job.save
      #  flash[:error] = 'There was a problem.'
      #  redirect_to :action => 'status', :id => params[job.id]
      #  return
      #end
      jobs << job
    end
    
    jobs.first.submit_jobs(jobs) if !jobs.empty?
    
    redirect_to :action => 'queue'
    return
  end

  # submit function for a ff input based job (primarily for manual overrides)
 def ffonly_submit
    @job = Job.new()
    @job.QueryString = params[:sequence]
    @job.Type = "FragFold"
    @job.name = params[:name]

    # log the submitting user... TODO add priority here too
    if (logged_in?)
      @job.user_id = self.current_user.id
    else
      @job.user_id = 0
    end

    # set config from drop down selection
    @job.configuration_id = params[:newjob][:configuration_id]
    # find the current active configuration for this job...
    #@curconfig = Configuration.find_by_active(true)
    #if (@curconfig)
    #      @job.configuration_id = @curconfig.id
    #    else
    #      @job.configuration_id = 0
    #    end
    overrides = params[:ff_overrides].split("\n")

    @job.ip = request.remote_ip
    #@job.address = "S.Ward@cs.ucl.ac.uk"
    @job.address = nil

    if @job.save!
      for override in overrides
        new_override = JobConfigOverride.create
        new_override.job_id = @job.id
        new_override.key = override.split("=").first
        new_override.value = override.split("=").last
        new_override.save!
      end
      @job.submit_jobs([@job])
      redirect_to :action => 'queue'
      return
    else
      flash[:error] = 'There was a problem.'
      format.html { render :action => "ffjob"}
      return
    end

  end

  def submit
    @job = Job.new()
    @job.QueryString = params[:sequence]
    @job.Type = params[:job_type]
    @job.name = params[:name]
    @job.QueryString.gsub!(/\n|\s/, "")

    # log the submitting user... TODO add priority here too
    if (logged_in?)
      @job.user_id = self.current_user.id
    else
      @job.user_id = 0
    end
    
    # set config from drop down selection
    @job.configuration_id = params[:newjob][:configuration_id]
    # find the current active configuration for this job...
    #@curconfig = Configuration.find_by_active(true)
    #if (@curconfig)
    #      @job.configuration_id = @curconfig.id
    #    else
    #      @job.configuration_id = 0
    #    end
    
    @job.ip = request.remote_ip
    #@job.address = "S.Ward@cs.ucl.ac.uk"
    @job.address = nil
    
    if @job.save!
      @job.submit_jobs([@job])
      redirect_to :action => 'queue'
      return
    else
      flash[:error] = 'There was a problem.'
      format.html { render :action => "newjob"}
      return
    end
    
  end


  def public_job
    redirect_to :controller => 'psipred', :action => 'index'
  end

    def destroy_job
    job = Job.find(params[:id])
    job.kill if ((job.state.to_i != 3) && (job.state.to_i != 4))
    job.destroy
    redirect_to :action => 'index'
  end

  def batch_destroy
    @page = params[:page]
    @jobs = Job.paginate :order => "created_at DESC", :page => @page, :per_page => 150
  end

  def batch_destroy_job
    params.each_pair do |name, checked|
      # skip form options and just get checkbox fields
      # could also salt checkboxes with some regex name to differentiate...
      if (name == 'action' || name == 'controller' || name == 'commit')
        next
      end
      if (checked)
        job = Job.find(name)
        job.kill if ((job.state.to_i != 3) && (job.state.to_i != 4))
        job.destroy
      end
    end

    redirect_to :action => 'index'
  end


end
