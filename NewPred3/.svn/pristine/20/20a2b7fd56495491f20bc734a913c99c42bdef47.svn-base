class TestHarness::DataManagerController < ApplicationController

  def index
    list_entries
    render :action => 'list_entries'
  end

  def getmodelattached
    model = TestModel.find(params[:id])
    send_data( model.pdb,
                :filename => "#{model.test_entry.name}_#{model.model_type}_#{model.id}.pdb",
                :type => "application/octet-stream",
                :disposition => "attachment")
  end
  
  def do_import_fasta
    require 'find'
    require 'bio'

    # Auto create an All test set as well if it doesn't exist...
    testgroup = TestSet.find_by_name("All")
    testgroup = TestSet.create(:name => "All", 
      :description => "Default Group for all sequences") if testgroup.nil?
    
    
    @root_dir = params[:fasta_dir]
    @root_dir = "#{@root_dir}/" if @root_dir.last != '/'
    logger.info("Searching #{@root_dir}")

    Find.find(@root_dir) do |path|
      if File.fnmatch?("*.fasta", path)
        logger.info("Loading #{path}")
        ffbuf = File.new(path).gets(nil)
        entry = Bio::FastaFormat.new(ffbuf)
        tempentry = TestEntry.new
        tempentry.sequence = entry.seq
        tempentry.comment = entry.entry_overrun
        #tempentry.name = entry.entry_id
        tempentry.name = File.basename(path, ".fasta")
        tempentry.transaction do
          tempentry.save!
          testgroup.test_entries << tempentry
          testgroup.save!
        end
      else
        next
      end
    end
    redirect_to :action => 'import_pdb'
  end
  
  def do_import_pdb
    require 'find'
    require 'bio'
    require 'bio/db/pdb'
    
    @root_dir = params[:pdb_dir]
    @root_dir = "#{@root_dir}/" if @root_dir.last != '/'
    model_type = ModelType.find_by_name("pdb_ref")
    model_type = ModelType.create(:name => 'pdb_ref') if model_type.nil?

    # Auto create a pdb_ref test set as well if it doesn't exist...
    testgroup = TestSet.find_by_name("pdb_ref")
    testgroup = TestSet.create(:name => "pdb_ref", 
      :description => "Default Group for all entries with a pdb structure") if testgroup.nil?
    
    logger.info("Searching #{@root_dir}")
    
    Find.find(@root_dir) do |path|
      modname = File.basename(path, ".pdb") if !File.directory?(path)

      #if ((modname != nil) && (File.fnmatch?("T*", modname)) 
      if ((modname != nil))
        logger.info("Loading #{path}")
        pf = File.new(path).gets(nil)
        #TODO fix bioruby pdb parser. for now, swap to biojava parser?
        #structure = Bio::PDB.new(pf)
        # Which chain should we read?
        logger.info("Associating with entry #{modname}")

        parent = TestEntry.find_by_name(modname)
        parent.test_sets << testgroup if !parent.nil?
        newmodel = TestModel.new()
        newmodel.model_type = model_type
        newmodel.pdb = pf
        newmodel.test_entry = parent if !parent.nil?
        #newmodel.alternate_sequence = structure.seqres()
        newmodel.save!
      else
        next
      end
    end
    redirect_to :action => 'import_models'
  end

  def do_import_models
    require 'find'

    @root_dir = params[:model_dir]
    @root_dir = "#{@root_dir}/" if @root_dir.last != '/'
    
    Find.find(@root_dir) do |path|
      next if File.directory?(path)
      
      if File.fnmatch?("*.submit1.pdb", path)
        modname = File.basename(path, ".submit1.pdb")
        modtype = File.dirname(path).split('/').last
        model_type = ModelType.find_by_name(modtype)
        model_type = ModelType.create(:name => modtype) if model_type.nil?
        
        logger.info("Inserting #{modname} into group #{modtype}")
        pf = File.new(path).gets(nil)
        parent = TestEntry.find_by_name(modname)
        newmodel = TestModel.new()
        newmodel.model_type = model_type
        newmodel.pdb = pf
        newmodel.test_entry = parent if parent != nil
        newmodel.save!
      else
        logger.info("Failed #{path}")
        next
      end
    end
    
    redirect_to :action => 'list_entries'
  end

  def list_entries
    # Note: security risk to allow SQL in like this...
    @entries_by = params[:order_by]
    @entries_by = "name ASC" if @entries_by.nil?
    @page = params[:page]
    
    @entries = TestEntry.paginate :order => @entries_by, :page => @page, :per_page => 25
    #@entry_pages, @entries = paginate  :test_entries,
  #                                  :order => @entries_by,
  #                                  :per_page => 25
  end

  def show_entry
    @entry = TestEntry.find(params[:id])
    @page = params[:page]
    @models = @entry.test_models.paginate :page => @page, :per_page => 10
  end
  
  def create_test_set
    newset = TestSet.new()
    newset.name = params[:name]
    newset.description = params[:description]
    newset.save!
    
    redirect_to :action => 'edit_test_sets'
  end
  
  def update_test_sets
    # Should add some better input validation here, but admin only so...
    logger.info(params)
    params.each_pair do |name, checked|
      # skip form options and just get checkbox fields
      # could also salt checkboxes with some regex name to differentiate...
      if (name == 'action' || name == 'controller' || name == 'commit')
        next
      end
      
      entryid = name.split('_').first
      setid = name.split('_').last
      entry = TestEntry.find(entryid)
      set = TestSet.find(setid)
      
      if (checked)
        entry.test_sets << set if !entry.test_sets.include?(set)
      else
        entry.test_sets.delete(set) if entry.test_sets.include?(set)
      end
    end
    
    redirect_to :action => 'list_test_sets'
  end
end
