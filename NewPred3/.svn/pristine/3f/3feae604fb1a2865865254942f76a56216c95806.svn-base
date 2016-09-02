class JobConfiguration < ActiveRecord::Base
  has_many :jobs
  has_many :test_runs
  has_many :configuration_entries, :dependent => :destroy
  has_and_belongs_to_many :servers
  
  attr_accessible :name, :comment, :active, :servers
  
  require 'will_paginate'
  require 'pp'
  
  def to_wire_format(additional_params)
    require 'yaml'
    elements = Hash.new
   
    for entry in configuration_entries
      # ugly hack to detect types from strings
      # try to represent as int, float, and finally string
      # TODO: replace this with a nice regex parse
      begin
        as_int = entry.value.to_i
        if (as_int.to_s == entry.value)
          elements.merge!(entry.key => as_int)
          next
        end
        as_float = entry.value.to_f
        if (as_float.to_s == entry.value)
          elements.merge!(entry.key => as_float)
          next
        end
      rescue        
      end
	   
       elements.merge!(entry.key => entry.value)
	   
      next
    end
    
    if (!additional_params.nil?)
      elements.merge!(additional_params)
    end
    
	elements.to_yaml
	
  end
  
  #no idea why this method requires self. in the declaration to work
  #but the other method does not require that.
  def self.pages (page)
	  paginate :page => page, :per_page => 10
	  
  end
  
end
