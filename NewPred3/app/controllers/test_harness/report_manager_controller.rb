class TestHarness::ReportManagerController < ApplicationController
  def index
    list_reports
    render :action => 'list_reports'
  end
  
  def do_create_report
    @new_report = Report.new
    @new_report.binary = params[:binary]
    @new_report.name = params[:name]
    @new_report.description = params[:description]
    @new_report.ref_model_type_id = params[:new_report][:ref_model_type_id]
    
    #check if the binary is a known one, and set score flag appropriately
    @new_report.has_score = @new_report.respond_to? "#{@new_report.get_bin_name}_score"
    
    for id in params[:new_report][:model_types]
      @new_report.model_types << ModelType.find(id)
    end
    @new_report.save!
    
    redirect_to :action => 'list_reports'
  end
  
  def new_report
    @new_report = Report.new
    pdb_ref = ModelType.find_by_name("pdb_ref")
    @new_report.ref_model_type_id = pdb_ref.id if !pdb_ref.nil?

  end

  def list_reports
    @reports_by = params[:order_by]
    @reports_by = "name ASC" if @reports_by.nil?
    @page = params[:page]
    #@report_pages, @reports = paginate :reports, :order => @reports_by, :per_page => 10
    @reports = Report.paginate :order => @reports_by, :page => @page, :per_page => 10
  end

  def do_run_report
    @report = Report.find(params[:id])
    @report.run_report

    redirect_to :action => 'show_report', :id => @report.id
  end
  
  def show_report
    @report = Report.find(params[:id])

    @elements = @report.report_elements.find(:all, :order => 'test_entries.name, model_types.name, score',
      :include => [ { :test_model => :test_entry}, {:test_model => :model_type}, {:test_model => :job } ] )
      
  end
   
  def show_report_overview
    @report = Report.find(params[:id])
    #@ref_entry = TestEntry.find(params[:ref_id])
    ref_model_type = ModelType.find(@report.ref_model_type_id)
    
    # contains all the summary stats, grouped by test entry
    @entries = Array.new
    
    # build a listing of the test entries used for this report
    test_entries = Set.new
    for ref_model in ref_model_type.test_models
      test_entries.add(ref_model.test_entry)
    end
    
    # do summary stats, grouped by test_entry and then by model type (ie, run)
    for ref_entry in test_entries
      entry = Hash.new
      
      details = Array.new
      for model_type in @report.model_types
        elements = @report.report_elements.find(:all, :conditions => [ "model_types.id = ? AND test_entries.id = ?", 
            model_type.id , ref_entry.id], :include => [ { :test_model => :test_entry}, {:test_model => :model_type}])
        scores = elements.collect { |element| element.score }
        stats = Hash.new
        sum = scores.sum
        
        # TODO: better stats
        stats["model_type"] = model_type.name
        stats["mean"] = 0
        stats["mean"] = sum / scores.length if scores.length != 0
        stats["min"] = scores.min
        stats["max"] = scores.max
        stats["count"] = scores.length
        details << stats
      end
      
      entry["stats"] = details
      entry["ref_entry"] = ref_entry
      @entries << entry
    end
    
  end
  
  def entry_summary_image
    require 'gruff'

    @report = Report.find(params[:id])
    @ref_entry = TestEntry.find(params[:ref_id])
    
    @entries = Array.new
    
    g = Gruff::Bar.new
    
    for model_type in @report.model_types
      elements = @report.report_elements.find(:all, :conditions => [ "model_types.id = ? AND test_entries.id = ?", 
          model_type.id , @ref_entry.id], :include => [ { :test_model => :test_entry}, {:test_model => :model_type}])
      scores = elements.collect { |element| element.score }
      stats = Hash.new
      histo = Hash.new(0)
      
      for score in scores
        histo[score.round] = histo[score.round] + 1
      end
      
      stats["histo"] = histo
      stats["test_entry"] = @ref_entry
      stats["model_type"] = model_type.name
      stats["scores"] = scores
      stats["mean"] = scores.sum / scores.length
      stats["min"] = scores.min
      stats["max"] = scores.max
      stats["count"] = scores.length
      
      @entries << stats
    end
    
    g.title = "#{@ref_entry.name} Breakout"
    
    # normalize the scale
    scale_min = @entries.min { |a, b| a["min"].round <=> b["min"].round }
    scale_max = @entries.max { |a, b| a["max"].round <=> b["max"].round}

    for entry in @entries
      histo = entry["histo"]
      
      for i in scale_min["min"].round..scale_max["max"].round
        histo[i] = histo[i]
      end
      
      g.data(entry["model_type"], histo.values)
    end
    
    labels = Hash.new
    j = 0
    toggle = true	
    for i in scale_min["min"].round..scale_max["max"].round
       labels[j] = i.to_s if toggle == true
       toggle = !toggle
       j = j + 1
    end
    
    
    g.labels = labels

    send_data g.to_blob('PNG'), :type => 'image/png', :disposition => 'inline'
  end
end
