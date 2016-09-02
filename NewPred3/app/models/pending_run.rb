class PendingRun < ActiveRecord::Base
  has_and_belongs_to_many :jobs
  belongs_to :test_run
  
  def store_to_tgz(tgz)
    return if (tgz.nil?)
    require 'archive/tar/minitar'
    require 'zlib'
    # store all the jobs in tgz files to make a master tarball
    archives = Array.new
    for job in jobs
      temp_tgz = Tempfile.new("bs_tgz")
      #temp_tgz.close(false)
      job.store_to_tgz(temp_tgz.path)
      archives << [job.name.split("_").first, temp_tgz]
	  temp_tgz.close(false)
    end
        
    Zlib::GzipWriter.open(tgz) do |gzip|
      Archive::Tar::Minitar::Output.open(gzip) do |out|
        # write the debug entries, filename by status field (with fixed spaces etc)
        for entry in archives
            out.tar().mkdir("#{entry.first}", :mode => 0755, :mtime => Time.now)
            out.tar().add_file_simple("#{entry.first}/#{entry.first}_full.tgz", :mode => 0600,
              :size => entry.last.length, :mtime => Time.now) do |stream, io|
              stream.write(entry.last.gets(nil))
          end
        end
      end
    end
    
    # clean up the temporary tgz files
    for entry in archives
      entry.last.close(true)
    end
  end
  
end
