class JobConfigurationsController < ApplicationController
   
  def index
    list
    render :action => 'list'
  end

  def list
    #@configuration_pages, @configurations = paginate :configurations, :per_page => 10
    @page = 0
	if params[:page].nil?
		@page = 1
	else
		@page = params[:page]
	end
	@configurations = JobConfiguration.pages(@page)
  end

  def show
    @configuration = JobConfiguration.find(params[:id])
    @entries = @configuration.configuration_entries
    @servers = @configuration.servers
    entry_hash = Hash.new
    for entry in @entries
      entry_hash[entry.key] = entry.value
    end
    
    @entry_hash_yaml = entry_hash.to_yaml 
  end

  def do_create_server
    server = Server.create(:name => params[:name], 
      :address => params[:address], :description => params[:description],
      :service => params[:service])
    flash[:notice] = "New Server #{server.address} added successfully" if !server.nil?
    redirect_to :action => 'list'
  end
  
  def new_server
    
  end
  
  def new
    @configuration = JobConfiguration.new
    # set some default values in line with base config
    @configuration.comment = "Default Values"
    @configuration.active = false
    @configuration.name = "Default"
          
    #    @configuration.BinDir = "/mnt/hgfs/pdbroot/software/psipred/bin/"
    #    @configuration.BlastBinDir = "/mnt/hgfs/pdbroot/software/blast/blast-2.2.17/bin/"
    #    @configuration.BlastCap = "6"
    #    @configuration.BlastDB = "/mnt/hgfs/pdbroot/blast/"
    #    @configuration.BlastData = "/mnt/hgfs/pdbroot/software/blast/blast-2.2.17/data/"
    #    @configuration.PDB_ROOT = "/mnt/hgfs/pdbroot/pdb/data/structures/divided/pdb/"
    #    @configuration.ServerName = "//localhost/newpredserver/"
    #    @configuration.ServerThreads = 5
    #    @configuration.TDB_DIR = "/mnt/hgfs/pdbroot/software/psipred/"
    #    @configuration.THREAD_DIR = "/mnt/hgfs/pdbroot/software/psipred/"
    #    @configuration.TempDir = "/var/tmp/"
    
  end

  def create
    newvals = params[:configuration]

    if (newvals[:servers].nil?)
      flash[:notice] = 'No Servers Defined!'
      redirect_to :action => 'list'
      return
    end
    
    # quick hack to turn the integer id's into server references
    for i in (0...newvals[:servers].length)
      server = Server.find(newvals[:servers][i])
      newvals[:servers][i] = server
    end
    
    @configuration = JobConfiguration.new(newvals)
    
    if @configuration.save
      initial_values = params[:initial_values]
      if ((!initial_values.nil?) && (initial_values.to_s.size > 5))
        entry_hash = YAML::load(initial_values)
        entry_hash.each do |key, value|
          new_entry = ConfigurationEntry.create(:key =>key, :value => value, :job_configuration_id => @configuration.id)
        end
      end

      flash[:notice] = 'Configuration was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @configuration = JobConfiguration.find(params[:id])
  end

  def update
    @configuration = JobConfiguration.find(params[:id])
    
    #update any changed keys
    for entry in @configuration.configuration_entries
      newval = params["#{entry.id}"]
      next if newval.nil?
      entry.value = newval
      entry.save!
    end
    
    # confirm that only one configuration is active...
    @configuration.transaction do
      @activeconfig = nil
      
	  ## bad hash?
      if (params[:configuration][:active])
        @activeconfig = JobConfiguration.find_by_active(:all)
        if (@activeconfig && @activeconfig.id != @configuration.id)
          @activeconfig.update_attribute(:active, false)
        end
      end
      
	  if (params[:newkey] != 'new key')
        entry = ConfigurationEntry.find_or_create_by_key_and_job_configuration_id(params[:newkey], @configuration.id)
        entry.value = params[:newvalue]
        entry.save!
	    entry = ConfigurationEntry.create(:key => params[:newkey], 
          :value => params[:newvalue], :job_configuration_id => @configuration.id) if entry.nil?
      end
      
	  newvals = params[:configuration]
      for i in (0...newvals[:servers].length)
        
		if newvals[:servers][i].nil? || newvals[:servers][i].length == 0 
			newvals[:servers].delete_at(i)
		end
	  end
	  
	  
	  # quick hack to turn the integer id's into server references
	  for i in (0...newvals[:servers].length)
        server = Server.find(newvals[:servers][i])
		newvals[:servers][i] = server
      end
      
      if @configuration.update_attributes(newvals)
        flash[:notice] = 'Configuration was successfully updated.'
        redirect_to :action => 'show', :id => @configuration
      else
        render :action => 'edit'
      end
    end

  end

  def destroy
    JobConfiguration.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end

 
