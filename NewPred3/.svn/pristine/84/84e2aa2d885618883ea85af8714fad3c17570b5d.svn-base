# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

class NewPredStatus
  attr_accessor :id
  attr_accessor :status
  attr_accessor :status_code
  attr_accessor :status_class
  attr_accessor :data
  
  def initialize(status)
   @id = status["ID"] if status.has_key? "ID"
   @status = status["STATUS"] if status.has_key? "STATUS"
   @status_code = status["CODE"] if status.has_key? "CODE"
   @status_class = status["CLASS"] if status.has_key? "CLASS"
   @data = status["DATA"] if status.has_key? "DATA"
   @data = status["BINDATA"] if status.has_key? "BINDATA"
  end
end


class NewPredClient
  require 'xmlrpc/client'

  def initialize(host, service)
    @host = host
    @service_name = service
    
    @server = XMLRPC::Client.new2(@host)
    @proxy = @server.proxy(@service_name)
    
  end
  
  def get_job_count ()
    return @proxy.getJobCount()
  end

  def add_job( nJobID, strJobClass, nJobPriority, strSeq, strAlternateConfig)
    return @proxy.addJob(nJobID, strJobClass, nJobPriority, strSeq, strAlternateConfig)
  end
  
  def get_status( nJobID )
    res = @proxy.getStatus(nJobID)
    #puts res
    status = nil
    if (!res.nil?)
      status = NewPredStatus.new(res)
      status = nil if (status.status_class == 1)
    end
    return status
  end
  
  def kill_job( nJobID )
    return @proxy.killJob(nJobID)
  end
end
