class Report < ActiveRecord::Base
  has_many :report_elements, :dependent => :destroy
  has_and_belongs_to_many :model_types
  
  def get_bin_name
    return File.basename(binary).split(' ').first.downcase
  end
  
  def do_compare(ref_model, target_model)
    begin
      ref_file = Tempfile.new("#{ref_model.test_entry.name}_#{ref_model.model_type.name}")
      ref_file.puts(ref_model.pdb)
      ref_file.close
      target_file = Tempfile.new("#{target_model.test_entry.name}_#{target_model.model_type.name}")
      target_file.puts(target_model.pdb)
      target_file.close
    
      report_element = ReportElement.new
      report_element.report = self
      report_element.test_model = target_model
      # call the report binary and store the output in data
      true_bin = binary.sub("%1", ref_file.path).sub("%2", target_file.path)
      logger.info "Running #{true_bin}"
      report_element.data = `#{true_bin}`
    
      report_element.score = self.send("#{self.get_bin_name}_score".intern, report_element.data) if self.has_score
      report_element.save!
    ensure
      ref_file.unlink if !ref_file.nil?
      target_file.unlink if !target_file.nil?
    end
  end
  
  def run_report
    # only run entries that have models of all listed types?
    ref_model_type = ModelType.find(self.ref_model_type_id)
    
    pending_run_map = []
    for model_type in self.model_types
      pending_run_map << [model_type, PendingRun.find_by_name(model_type.name)]
    end
    
    for ref_model in ref_model_type.test_models
      for pr_ent in pending_run_map
        #test_models = pr_ent.first.test_models.find_all_by_test_entry_id(ref_model.test_entry_id)
        test_models = pr_ent.first.test_models.find(:all, :conditions => "test_entry_id = #{ref_model.test_entry_id}")
        next if (test_models.nil? || test_models.length < 1)
        for test_model in test_models
          do_compare(ref_model, test_model)
        end
      end
    end
    self.last_run = DateTime.now
    self.save!
  end
  
  # score retrieval functions. Name them binary_score, where binary is the binary name
  def tmalign_score(data)
    return data.scan(/TM-score=([0-9]+.[0-9]+),/).first.first
  end
  
  def gdtlist_score(data)
    return data.scan(/GDT-TS = ([0-9]+.[0-9]+) NE/).first.first
  end
  
end
