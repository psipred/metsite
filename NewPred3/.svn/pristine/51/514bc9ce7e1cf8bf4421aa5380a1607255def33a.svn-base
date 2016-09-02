class RequestResult < ActiveRecord::Base
  
  belongs_to :job
  has_many :thumbnails, :dependent => :destroy
  
  def set_data(name, type, data)
    self.data = data
    self.content_type = type
    self.content_name = name
  end
end
