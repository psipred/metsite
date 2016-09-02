class TestRun < ActiveRecord::Base
  has_many :pending_runs, :dependent => :destroy
  belongs_to :configuration
  belongs_to :test_set
end
