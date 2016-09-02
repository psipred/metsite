class TestModel < ActiveRecord::Base
  belongs_to :test_entry
  belongs_to :model_type
  belongs_to :job
  has_many :report_elements
  
  def self.fix_model_types
    model_type = ModelType.find_by_name("PendingRun")
    all_models = model_type.test_models
    for model in all_models
      job = model.job
      model_type = ModelType.find_by_name(job.pending_runs.first.name)
      model_type = ModelType.create(:name => job.pending_runs.first.name) if model_type.nil?
      model.model_type = model_type
      model.save!
    end
  end
end
