class Genome3dController < ApplicationController
  
  def index
  end
  
  def read
    #this will read the data out of the table/tables stick it in to the appropriate Job and request_results objects then render the psipred/results view.
    #TODO: sanity check all params in params[]
    
    id = params[:uniprot_id]
    stored_data =  Genome3d.by_uniprot_id(id)
    uniprot_info = Uniprot.by_uniprot_id(id)
    uniprot_info = uniprot_info[0] 
    
    #we make a dummy job object for the results page, note that we DO NOT save this to the db.
    @job = Job.new()
    @job.program_psipred = 0
    @job.program_disopred = 0
    @job.program_mgenthreader = 0
    @job.program_svmmemsat = 0
    @job.program_bioserf = 0
    @job.program_dompred = 0
    @job.program_ffpred = 0
    @job.program_genthreader = 0
    @job.program_mempack = 0
    @job.program_domthreader = 1
    @job.program_domserf = 1
    if ! uniprot_info.nil?
    @job.QueryString = uniprot_info.QueryString
    end
    @job.name = "DomSerf output for Genome3D"
    @job.UUID = id
    
    #we'll get the data from the table and then push the results into and array of request results
    @job_results = []
    
    stored_data.each do |row|
      result_row = RequestResult.create()
      result_row.status = row.status
      result_row.status_class = row.status_class
      result_row.created_at = row.created_at
      result_row.content_type = row.content_type
      result_row.content_name = row.content_name
      result_row.data = row.data
      result_row.id = row.id
      @job_results.push result_row 
     end
     @genome3d = 1
     respond_to do |format|
       if(uniprot_info.nil?)
         format.html { render :action => "error"}
       else
         format.html { render :template => 'psipred/result' }
       end
     end
     #lastly we redirect to the psipred controller results page. If there are results then send to page else send to NO results page also if the uniport ID does not exist
  end
  
end