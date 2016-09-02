class TestHarness::RunManagerController < ApplicationController

  def download_run
    pending_run = PendingRun.find(params[:id])
    tgz = Tempfile.new("bs_tgz")
    tgz.close(false)
    pending_run.store_to_tgz(tgz.path)
    send_file( tgz.path, :filename => "#{pending_run.test_run.name}_full.tgz", 
      :disposition => "attachment")
    #tgz.unlink
  end
  
  def process_pending (pending_job)
    #get all the pending jobs associated with this run
    jobs = pending_job.jobs
    return if jobs.nil?
    
    model_type = ModelType.find_by_name(pending_job.name)
    model_type = ModelType.create(:name => pending_job.name) if model_type.nil?
    
    for job in jobs
      job_state_before = job.state
      job.poll_status if (job_state_before != 4)
      job_state_after = job.state
      # state changed to complete
      if ((job_state_before != job_state_after) && (job_state_after == 4))
        models = job.get_models
        entry_id = job.name.split("_").last
        
        logger.info("found #{models.length} models for #{entry_id}")
        for model in models
          test_model = TestModel.create()
          test_model.pdb = model
          test_model.model_type = model_type
          test_model.test_entry_id = entry_id
          test_model.job_id = job.id
          test_model.save!
        end
      end
    end
  end
  
  def queue_run
    newrun = TestRun.find(params[:id])
    # get the test entries associate with the run
    entries = newrun.test_set.test_entries.collect
    return if entries.nil?
    
    if (logged_in?)
      userid = self.current_user.id
    else
      userid = 0
    end
    
    pending_run = PendingRun.create(:test_run_id => newrun.id)
    pending_run.name = "#{newrun.name}_#{newrun.pending_runs.count}"
    
    jobs = nil
    for entry in entries
      newjob = Job.create
      newjob.QueryString = entry.sequence
      newjob.Type = newrun.job_type
      newjob.configuration = newrun.configuration
      newjob.ip = request.remote_ip
      newjob.state = 0
      newjob.user_id = userid
      newjob.name = "#{entry.name}_#{pending_run.id}_#{entry.id}"
      newjob.pending_runs << pending_run
      if jobs.nil?
        jobs = [ newjob ]
      else
        jobs << newjob
      end 
      newjob.save!
    end
    pending_run.save!
    
    jobs.first.submit_jobs(jobs) if !(jobs.nil?)
    flash[:notice] = "#{jobs.length} jobs queued successfully." if !(jobs.nil?)
    redirect_to :action => 'show_run', :id => params[:id]
  end
  
  
  def do_create_run
    @new_test_run = TestRun.new
    @new_test_run.name = params[:name]
    @new_test_run.configuration_id = params[:new_test_run][:configuration_id]
    @new_test_run.test_set_id = params[:new_test_run][:test_set_id]
    @new_test_run.description = params[:description]
    @new_test_run.job_type = params[:job_type]
    
    @new_test_run.save!
    redirect_to :action => 'list_runs'
  end
  
  def create_run
    @new_test_run = TestRun.new
    @new_test_run.configuration = Configuration.find_by_active(true)
    @new_test_run.test_set = TestSet.find_by_name("All")
  end

  def index
    list_runs
    render :action => 'list_runs'
  end
  
  def list_runs
    # Note: security risk to allow SQL in like this...
    @page_runs_by = params[:order_by]
    @page_runs_by = "name ASC" if @page_runs_by.nil?
    @page = params[:page]
    #@testrun_pages, @testruns = paginate :test_runs, :order => @page_runs_by, :per_page => 10
    @testruns = TestRun.paginate :order => @page_runs_by, :page => @page, :per_page => 10
  end
  
  def show_run
    @testrun = TestRun.find(params[:id])
    @pending_runs = @testrun.pending_runs.collect
    #for pending_run in @pending_runs
    #  process_pending(pending_run)
    #end
  end
  
end
