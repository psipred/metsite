class TestSet < ActiveRecord::Base
  has_and_belongs_to_many :test_entries
  has_many :test_runs, :dependent => :destroy
end
