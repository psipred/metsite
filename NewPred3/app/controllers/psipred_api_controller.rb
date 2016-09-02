class PsipredApiController < ApplicationController

  include WashOut::SOAP
  include PsipredApiHelper
  include ControllerTools

  require 'pp'
  ########################
  #
  # BEGIN PSIPRED ACTIONS
  #
  ########################

  soap_action "PsipredSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :complex => :string, :membrane => :string, :coil => :string, :msa_control => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def PsipredSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],params[:complex],params[:membrane],params[:coil],params[:msa_control],0,"no","no",0,0,'no','no',"argh","psipred")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "PsipredResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :psipred_postscript => :string, :psipred_results => :string}

  def PsipredResult
    resultGetter(params[:job_id])
  end

  ########################
  #
  # END PSIPRED ACTIONS
  #
  ########################

  ########################
  #
  # BEGIN MEMSATSVM ACTIONS
  #
  ########################

  soap_action "MemsatsvmSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :msa_control => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def MemsatsvmSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'false','false','false',params[:msa_control],0,"no","no",0,0,'no','no',"argh","svmmemsat")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "MemsatsvmResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :memsat3_data => :string, :memsat3_image => :string, :memsatsvm_data => :string, :memsatsvm_image => :string, :memsatsvm_schematic => :string}

  def MemsatsvmResult
    resultGetter(params[:job_id])
  end

  ########################
  #
  # END MEMSATSVM ACTIONS
  #
  ########################

  ########################
  #
  # BEGIN DISOPRED ACTIONS
  #
  ########################

  soap_action "DisopredSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :fpr=> :string, :psiblast => :string, :psipred => :string},
    :return => { :message => :string, :job_id => :string, :state => :int}

  def DisopredSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'true','false','false','all',params[:fpr],params[:psiblast],params[:psipred],0,0,'no','no',"argh","disopred")
    #render :soap => { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "DisopredResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :disopred_pbdat => :string, :disopred_diso => :string, :disopred_diso2 => :string, :postscript_graph => :string, :psiblast => :string}

  def DisopredResult
    resultGetter(params[:job_id])
  end

  ########################
  #
  # END DISOPRED ACTIONS
  #
  ########################

  ########################
  #
  # END MEMPACK ACTIONS
  #
  ########################

  soap_action "MempackSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :msa_control => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def MempackSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'false','false','false',params[:msa_control],0,"no","no",0,0,'no','no',"argh","mempack")
    render :soap => { :message => message, :job_id => uuid, :state => state}
  end

  soap_action "MempackResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :memsat3_data => :string, :memsat3_image => :string, :memsatsvm_data => :string, :memsatsvm_image => :string, :memsatsvm_schematic => :string, :mempack_cartoon => :string, :graph_results => :string, :lipid_results => :string, :contact_results => :string}

  def MempackResult
    resultGetter(params[:job_id])
  end

  ########################
  #
  # END MEMPACK ACTIONS
  #
  ########################

  ########################
  #
  # END DOMPRED ACTIONS
  #
  ########################

  soap_action "DompredSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :eval => :string, :iterations => :string, :secpro => :string, :pp => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def DompredSubmit
    
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'true','false','false','all',0,"no","no",params[:eval],params[:iterations],params[:secpro],params[:pp],"argh","dompred")
    render :soap => { :message => message, :job_id => uuid, :state => state}
  end

  soap_action "DompredResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :dompred_graph => :string, :dompred_output => :string, :psiblast_output => :string, :psiblast_table => :string, :domssea_table => :string, :psipred_ps => :string}

  def DompredResult
    resultGetter(params[:job_id])
  end

  ########################
  #
  # END DOMPRED ACTIONS
  #
  ########################

  ############################
  #
  # START GENTHREADER ACTIONS
  #
  ############################

  soap_action "GenthreaderSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :complex => :string, :membrane => :string, :coil => :string},
    :return => { :message => :string, :job_id => :string, :state => :int}

  def GenthreaderSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],params[:complex],params[:membrane],params[:coil],'all',0,"no","no",0,0,'no','no',"argh","genthreader")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }

  end

  soap_action "GenthreaderResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :genthreader_data => :string, :contact_alignment => :string, :cert_alignment => :string, :cert_high_alignment => :string, :cert_high_med_alignment => :string}

  def GenthreaderResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END GENTHREADER ACTIONS
  #
  ###########################

  ###########################
  #
  # START BIOSERF ACTIONS
  #
  ###########################

  soap_action "BioserfSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :modeller => :string},
    :return => { :message => :string, :job_id => :string, :state => :int}

  def BioserfSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'true','false','false','all',0,"no","no",0,0,'no','no',params[:modeller],"bioserf")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "BioserfResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :mgenthreader_templates => :string, :psiblast_templates => :string, :selected_templates => :string, :model_pdb => :string}

  def BioserfResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END BIOSERF ACTIONS
  #
  ###########################

  ###########################
  #
  # END MGENTHREADER ACTIONS
  #
  ###########################

  soap_action "MgenthreaderSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :complex => :string, :membrane => :string, :coil => :string, :msa_control => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def MgenthreaderSubmit

    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],params[:complex],params[:membrane],params[:coil],'all',0,"no","no",0,0,'no','no',"argh","mgenthreader")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }

  end

  soap_action "MgenthreaderResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :genthreader_data => :string, :contact_alignment => :string, :cert_alignment => :string, :cert_high_alignment => :string, :cert_high_med_alignment => :string}

  def MgenthreaderResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END MGENTHREADER ACTIONS
  #
  ###########################

  ###########################
  #
  # START FFPRED ACTIONS
  #
  ###########################

  soap_action "FfpredSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def FfpredSubmit

    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'true','false','false','all',2,"opnone","true",0.01,5,'yes','yes',"argh","ffpred")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }

  end

  soap_action "FfpredResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :go_table => :string, :ffpred_data => :string, :seq_feature_map => :string, :transmembrane_diagram => :string}

  def FfpredResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END FFPRED ACTIONS
  #
  ###########################

  ###########################
  #
  # START DOMTHREADER ACTIONS
  #
  ###########################

  soap_action "DomthreaderSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :complex => :string, :membrane => :string, :coil => :string, :msa_control => :string  },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def DomthreaderSubmit

    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],params[:complex],params[:membrane],params[:coil],'all',0,"no","no",0,0,'no','no',"argh","domthreader")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }

  end

  soap_action "DomthreaderResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :domthreader_data => :string}

  def DomthreaderResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END DOMTHREADER ACTIONS
  #
  ###########################

  ###########################
  #
  # START HSPRED ACTIONS
  #
  ###########################

  soap_action "HspredSubmit",
    :args   => { :pdb_file => :string, :email => :string, :name => :string, :chainsa => :string, :chainsb => :string },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def HspredSubmit

    (message, uuid, state) = structureSubmitter(params[:pdb_file],params[:email],params[:name],params[:chainsa],params[:chainsb], "1", "CA","A","hspred")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }

  end

  soap_action "HspredResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :annotated_pdb_a => :string, :annotated_pdb_b => :string, :hspred_data => :string }

  def HspredResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END HSPRED ACTIONS
  #
  ###########################

  ###########################
  #
  # START METSITE ACTIONS
  #
  ###########################

  soap_action "MetsiteSubmit",
    :args   => { :pdb_file => :string, :email => :string, :name => :string, :fpr => :integer, :mettype => :string, :chain => :string },
    :return => { :message => :string, :job_id => :string, :state => :int}

  def MetsiteSubmit
    (message, uuid, state) = structureSubmitter(params[:pdb_file],params[:email],params[:name],"A","B",params[:fpr] ,params[:mettype] ,params[:chain],"metsite")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "MetsiteResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :annotated_pdb => :string, :metsite_data => :string }

  def MetsiteResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END METSITE ACTIONS
  #
  ###########################

  ###########################
  #
  # START MAKETDB ACTIONS
  #
  ###########################

  soap_action "MaketdbSubmit",
    :args   => { :pdb_file => :string, :email => :string, :name => :string},
    :return => { :message => :string, :job_id => :string, :state => :int}

  def MaketdbSubmit

    (message, uuid, state) = structureSubmitter(params[:pdb_file],params[:email],params[:name],"A","B", "1", "CA","A","maketdb")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "MaketdbResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :tdb_file => :string }

  def MaketdbResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END MAKETDB ACTIONS
  #
  ###########################
  

  ###########################
  #
  # START BOMSERF ACTIONS
  #
  ###########################

  soap_action "DomserfSubmit",
    :args   => { :sequence => :string, :email => :string, :name => :string, :modeller => :string},
    :return => { :message => :string, :job_id => :string, :state => :int}

  def DomserfSubmit
    (message, uuid, state) = sequenceSubmitter(params[:sequence],params[:email],params[:name],'true','false','false','all',0,"no","no",0,0,'no','no',params[:modeller],"domserf")
    #render soap: { :message => @message, :job_id => @job.UUID, :state => @state.to_i}
    render :soap => { :message => message, :job_id => uuid, :state => state }
  end

  soap_action "DomserfResult",
    :args   => { :job_id => :string },
    :return => { :message => :string, :job_id => :string, :state => :int, :alignments => :string, :pdb_templates => :string, :domain_templates => :string, :model_pdb => :string}

  def DomserfResult
    resultGetter(params[:job_id])
  end

  ###########################
  #
  # END DOMSERF ACTIONS
  #
  ###########################

  ##
  #
  # The functions below handle the data submision and results gathering, they are a bit long winded and could possibly be reorganised to be a little more legible. 
  #
  ##

  def sequenceSubmitter(sequence, email, name, complex, membrane, coil, msa_control,fpr, psiblast, psipred, eval, iterations, secpro, pp, modeller,type)

    #sanitise inputs. set to default if nonsense arrives
    if type =~ /^dompred/
      if eval !~ /^\d+\.\d+$|^\d+$/
      eval = 0.01
      end
      if iterations !~ /^\d+$/
      iterations = 5
      end
      if secpro !~ /^yes$|^no/
        secpro = 'yes'
      end
      if pp !~ /^yes$|^no/
        pp = 'yes'
      end
    end

    if type =~ /^psipred|^genthreader|^mgenthreader|^domthreader/
      if complex !~ /^true$|^false$/
        complex = 'true'
      end
      if membrane !~ /^true$|^false$/
        membrane = 'false'
      end
      if coil !~ /^true$|^false$/
        coil = 'false'
      end
    end

    if type =~ /^disopred/
      #sanitise inputs. set to default if nonsense arrives
      if fpr !~ /^1$|^2$|^3$|^4$|^5$|^6$|^7$|^8$|^9$|^10$/
      fpr = 2
      end
      if psiblast !~ /^opnone$|^ophits$|^opaln$/
        psiblast = 'opnone'
      end
      if psipred !~ /^true$|^false$/
        psipred = 'true'
      end
    end

    @job = Job.new()
    @msa_found = 0

    setStandardJobSettings(sequence,email,name)

    if type =~ /^psipred/
    @job.program_psipred = 1
    else
    @job.program_psipred = 0
    end
    if type =~ /^disopred/
    @job.program_disopred = 1
    else
    @job.program_disopred = 0
    end
    if type =~ /^mgenthreader/
    @job.program_mgenthreader = 1
    else
    @job.program_mgenthreader = 0
    end
    if type =~ /^svmmemsat/
    @job.program_svmmemsat = 1
    else
    @job.program_svmmemsat = 0
    end
    if type =~ /^bioserf/
    @job.program_bioserf = 1
    else
    @job.program_bioserf = 0
    end
    if type =~ /^dompred/
    @job.program_dompred = 1
    else
    @job.program_dompred = 0
    end
    if type =~ /^ffpred/
    @job.program_ffpred = 1
    else
    @job.program_ffpred = 0
    end
    if type =~ /^genthreader/
    @job.program_genthreader = 1
    else
    @job.program_genthreader = 0
    end
    if type =~ /^mempack/
    @job.program_mempack = 1
    else
    @job.program_mempack = 0
    end
    if type =~ /^domthreader/
    @job.program_domthreader = 1
    else
    @job.program_domthreader = 0
    end
    if type =~ /^domserf/
    @job.program_domserf = 1
    else
    @job.program_domserf = 0
    end
    
    setAdditionalJobs()
    @job.ip = setIP()
    job_count = Job.countJobs(@job.ip)
    setUserID()

    @model_test = 1
    #TODO: this is a hard coded instance of the modeller licence key, should ideally test against the modeller executable as in the
    #bioserf public_submission controller but that code doesn't appear to work here in the Model section
    if modeller !~ /MODELIRANJE/
      @model_test = 0
    end

    @state = 0
    #we set the state depending on whether job submission was succesful.
    #state 0 = not successful
    #state 1 = successful submission
    begin
      if(@msa_found == 1 && @job.Type =~ /^genthreader||^memsat/)
        @error_message = "MSA input not available for genTHREADER or MEMSAT. For genTHREADER please use mGenTHREADER or domTHREADER"
        @state=0
      elsif @model_test == 0 && type =~ /^bioserf|domserf/
        @message = "Modeller Licence Key invalid."
        @state=0
      elsif(job_count >= 20 && @job.user_id != 0)
        @message = "You have 20 live jobs, #{ip}.  Please wait until your jobs have finished before submitting more. "
        @state = 0
      elsif(@job.user_id == 0 && job_count >= 30)
        @message = "You have 30 live jobs, #{ip}.  Please wait until your jobs have finished before submitting more. "
        @state = 0
      else
        @job.save!
        #create an object for each override settings.  Then save all the settings that will override the job defaults
        #kind of ugly. Is there a cleaner way to do this?

        if type =~ /^genthreader|^mgenthreader|^domthreader|^bioserf|^domserf/
          overrider("TS_MGT_MIN_MIN_SCORE",35)
        end
        overrider("complex_filter_setting", complex )
        overrider("coil_filter_setting", coil )
        overrider("membrane_filter_setting", membrane )
        if type =~ /^bioserf|^domserf/
          overrider("result_filter_setting", "GUESS" )
        else
          overrider("result_filter_setting", "MEDIUM" )
        end
        overrider("msa_control_setting", msa_control )
        overrider("msa_input", @msa_found )
        if type =~ /disopred|ffpred/
          overrider("false_positive_setting",fpr)
          overrider("secondary_structure_prediction",psipred)
          overrider("psiblast_output_option",psiblast)
        end
        if type =~ /dompred|ffpred/
          overrider("psi_blast_iterations",iterations)
          overrider("perform_psiblast","yes")
          overrider("psiblast_output_option","yes")
          overrider("database","PfamA")
          overrider("e_value",eval)
          overrider("perform_domssea","yes")
          overrider("include_sec_structure_plot",secpro)
          overrider("display_psipred",pp)
        end
        if type =~ /domserf/
          overrider("psi_blast_iterations",5)
        end
        assignProgramOverrides()
        assignCacheOverrides()

        #actually submit the job (expect and array of job objects as the function isn't overloaded)
        @job.submit_jobs([@job])
        @message = "job submission succesful"
        @state = 1
      end
    rescue Exception => e
      logger.debug e.to_s
      @state = 0
      if @job && ! @job.errors.empty?
        errors = @job.errors.collect { |msg| msg }
        errors.each do |error|
          error.each do |entry|
            if entry !~ /QueryString/
              @message= @message+entry+". "
            end
          end
        end
      end
    end

    return @message, @job.UUID, @state.to_i

  end

  def structureSubmitter(pdb_data, email, name, chainsa, chainsb, fpr, mettype, chain, type)

    @job = Job.new()
    setStandardStructSettings(pdb_data,email,name)

    if type =~ /metsite/
      #sanitize inputs
      if fpr =~ /^1$/
      fpr = 0
      elsif fpr =~ /^5$/
      fpr = 1
      elsif fpr =~ /^10$/
      fpr = 2
      elsif fpr =~ /^20$/
      fpr = 3
      else
      fpr = 0
      end
    end

    if mettype !~ /^CA$|^ZN$|^MG$|^FE$|^CU$|^MN$/
      mettype = 'CA'
    end

    #@job.ip = request.remote_ip

    if type =~ /^hspred/
    @job.program_hspred = 1
    else
    @job.program_hspred = 0
    end
    if type =~ /^metsite/
    @job.program_metsite = 1
    else
    @job.program_metsite = 0
    end
    if type =~ /^maketdb/
    @job.program_maketdb = 1
    else
    @job.program_maketdb = 0
    end
    setAdditionalJobs()

    #@job.ip = request.remote_ip, find out from where our user has submitted their job
    tmp_ip = request.env["HTTP_X_FORWARDED_FOR"]
    if(tmp_ip =~ /(\d+\.\d+\.\d+\.\d+)$/)
    tmp_ip = $1;
    else
      tmp_ip = request.remote_ip
    end
    @job.ip = tmp_ip

    chainsA = chainsa
    chainsA.upcase!
    chainsA.gsub!(/\n|\s/, "")
    chainsA.gsub!(/\W|\d/, "")
    chainsB = chainsb
    chainsB.upcase!
    chainsB.gsub!(/\n|\s/, "")
    chainsB.gsub!(/\W|\d/, "")

    job_count = Job.countJobs(@job.ip)
    setUserID()

    @message = String.new
    @state = 0
    #we set the state depending on whether job submission was succesful.
    #state 0 = not successful
    #state 1 = successful submission
    begin
      if(job_count >= 20 && @job.user_id != 0)
        @message = "You have 20 live jobs, #{ip}.  Please wait until your jobs have finished before submitting more. "
        @state = 0
      elsif(@job.user_id == 0 && job_count >= 30)
        @message = "You have 30 live jobs, #{ip}.  Please wait until your jobs have finished before submitting more. "
        @state = 0
      else
        @job.save!

        overrider("metal_site_classifier",mettype)
        overrider("false_positive_setting",fpr)
        overrider("chain_id", chain)
        overrider("chains_a", chainsA )
        overrider("chains_b", chainsB )
        overrider("program_hspred",@job.program_hspred)
        overrider("program_metsite",@job.program_metsite)
        overrider("program_maketdb",@job.program_maketdb)

        #actually submit the job (expect and array of job objects as the function isn't overloaded)
        @job.submit_jobs([@job])
        @message = "job submission succesful"
        @state = 1
      end
    rescue Exception => e
      @state = 0
      if @job && ! @job.errors.empty?
        errors = @job.errors.collect { |msg| msg }
        errors.each do |error|
          error.each do |entry|
            if entry !~ /QueryString/
              @message= @message+entry+". "
            end
          end
        end
      end
    end

    return @message, @job.UUID, @state.to_i
  end

  def resultGetter(job_id)

    #getting the data for the incoming job ID, the exception handling allows us to handle throwing an error view if the ID
    #is wrong
    begin
    #@job = Job.find(job_id)
      @job_tmp = Job.find(:all, :conditions => "UUID=\"#{job_id}\"")
      @job = @job_tmp[0]
      @job_results = @job.request_results.find(:all)

      #loop through the job states to find out what state the job finished in.  Did it complete?
      job_complete = 0

      if @job.state == 3
        job_complete = 2
        @error_message = "An internal server error has caused this job to fail"
      end

      @job_results.each do |job_state|
        if (job_state.status =~ /Job Complete/)
        job_complete = 1
        end
        if (job_state.status_class == 3)
          job_complete = 2
          @error_message = job_state.status
        end
      end

    rescue
    job_complete=3
    end
    #set everything to unfound before looping through the results
    psipred_postscript = "No data"
    psipred_results = "No data"
    memsat3_image = "No data"
    memsat3_data = "No data"
    memsatsvm_image = "No data"
    memsatsvm_data = "No data"
    memsatsvm_schematic = "No data"
    disopred_pbdat = "No data"
    disopred_diso = "No data"
    disopred_diso2 = "No data"
    psiblast = "No data"
    postscript_graph = "No data"
    mempack_cartoon = "No data"
    graph_results = "No data"
    lipid_results = "No data"
    contact_results = "No data"
    dompred_graph = "No data"
    dompred_output = "No data"
    psiblast_output = "No data"
    psiblast_table = "No data"
    domssea_table = "No data"
    psipred_ps = "No data"
    genthreader_data = "No data"
    contact_alignment = "No data"
    cert_alignment = "No data"
    cert_high_alignment = "No data"
    cert_high_med_alignment = "No data"
    model_pdb = "No data"
    mgenthreader_templates = "No data"
    psiblast_templates = "No data"
    selected_templates = "No data"
    go_table = "No data"
    ffpred_data = "No data"
    seq_feature_map = "No data"
    transmembrane_diagram = "No data"
    domthreader_data = "No data"
    annotated_pdb_a = "No data"
    annotated_pdb_b = "No data"
    hspred_data = "No data"
    index=0
    annotated_pdb = "No data"
    metsite_data = "No data"
    tdb_file = "No data"
    output_message = 'Success'
    pir_alignments = "No data"
    pdb_templates = "No data"
    domain_templates = "No data"
    final_state = 1

    if(job_complete == 1)
      @job_results.each do |job_state|

        if (job_state.status_class == 53)
          tdb_file = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 11 && @job.Type =~ /seqJob/)
          psipred_results = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 12 )
          psipred_postscript = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 20)
          memsat3_image = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 16 )
          memsat3_data= "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 32)
          memsatsvm_image = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 19)
          memsatsvm_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 21)
          memsatsvm_schematic = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 24 )
          disopred_pbdat = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 25 )
          disopred_diso = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 101 )
          disopred_diso2 = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 26 ) && (job_state.content_name =~ /\.blast\.gz/)
          psiblast = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 12 )
          if job_state.content_name =~ /diso\.ps/
            postscript_graph = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end

        if job_state.status_class == 43 
          mempack_cartoon = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 45)
          graph_results = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 46)
          lipid_results = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 47)
          contact_results = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 44)
          output_message="MEMPACK predicted fewer than 2 helices"
        end
        if (job_state.status_class == 52)
          output_message="MEMPACK produced no helix contacts"
        end

        if (job_state.status_class == 14 && job_state.content_name =~ /myps/)
          dompred_graph = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 28 )
          dompred_output = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 26 ) && (job_state.content_name =~ /\.blast\.gz/)
          psiblast_output = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 29 )
          psiblast_table = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 27 )
          domssea_table = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if(job_state.status_class == 12 )
          psipred_ps = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 9 && job_state.content_name =~ /^Gen Template Group/)
          genthreader_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 50 )
          contact_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 51 )
          if job_state.content_name =~ /cert\.multialign/
            cert_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
          if job_state.content_name =~ /certhigh\.multialign/
            cert_high_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
          if job_state.content_name =~ /all\.multialign/
            cert_high_med_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end
        if (job_state.status_class == 6 )
          if model_pdb !~ /No data/
            model_pdb = model_pdb + ",http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          else
            model_pdb = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end
        if (job_state.status_class == 4 )
          if(job_state.status =~ /Blast templates/)
            psiblast_templates = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          elsif(job_state.status =~ /mGen Template Group/)
            mgenthreader_templates = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          elsif(job_state.status =~ /Selected Aligned Templates/)
            selected_templates = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end

        if (job_state.status_class == 77 && job_state.content_name =~ /^mGen Template Group/)
          genthreader_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 80 )
          contact_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 81 )
          if job_state.content_name =~ /cert\.multialign/
            cert_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
          if job_state.content_name =~ /certhigh\.multialign/
            cert_high_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
          if job_state.content_name =~ /all\.multialign/
            cert_high_med_alignment = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end
        if (job_state.status_class == 88)
          go_table = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 38 )
          ffpred_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 39 )
          seq_feature_map = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 40 )
          transmembrane_diagram = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 10)
          domthreader_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 34)
          if index == 0
            annotated_pdb_a = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          index+=1
          end
          if index == 1
            annotated_pdb_b = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end
        if (job_state.status_class == 33)
          hspred_data = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end

        if (job_state.status_class == 23)
          annotated_pdb = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 92)
          output_message = job_state.status
        end
        if (job_state.status_class == 93)
          output_message = job_state.status
        end
        if (job_state.status_class == 94)
          output_message = job_state.status
        end
        if (job_state.status_class == 95)
          pdb_templates = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 96)
          domain_templates = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
        end
        if (job_state.status_class == 97)
          if pir_alignments !~ /No data/
             pir_alignments = pir_alignments+",http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          else
            pir_alignments = "http://bioinf.cs.ucl.ac.uk/bio_serf/getresultattached/" + job_state.id.to_s
          end
        end
        
        if(job_state.status_class == 3 || job_state.status_class == 58 || job_state.status_class == 59 || job_state.status_class == 60 || 
          job_state.status_class == 61 || job_state.status_class == 62 || job_state.status_class == 63 || job_state.status_class == 64 || 
          job_state.status_class == 65 || job_state.status_class == 66 || job_state.status_class == 67 || job_state.status_class == 68 || 
          job_state.status_class == 69 || job_state.status_class == 84 || job_state.status_class == 85 || job_state.status_class == 86 ||
          job_state.status_class == 91)
          output_message = job_state.content_name
          final_state = 3
        end

      end

      #we need an elegant way to handle error messages should one of the states be 3 

      #the logic here ensures given the jobs chosen that we return the correct results response.
      #Note that for jobs which can run as subparts of other jobs the logic must exclude the render from potentially being called twice.
      if (@job.program_psipred == 1 || @job.program_psipred == 3) && @job.program_domserf == 0 && @job.program_bioserf == 0 && @job.program_mgenthreader == 0 && @job.program_dompred == 0 && @job.program_domthreader == 0 && @job.program_ffpred == 0 && @job.program_disopred == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :psipred_postscript => psipred_postscript, :psipred_results => psipred_results}
      end
      if(@job.program_svmmemsat == 1 || @job.program_svmmemsat == 3) && @job.program_ffpred == 0 && @job.program_mempack == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :memsat3_data => memsat3_data, :memsat3_image => memsat3_image, :memsatsvm_data => memsatsvm_data, :memsatsvm_image => memsatsvm_image, :memsatsvm_schematic => memsatsvm_schematic}
      end
      if (@job.program_disopred == 1 || @job.program_disopred == 3)&& @job.program_ffpred == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :disopred_pbdat => disopred_pbdat, :disopred_diso => disopred_diso, :disopred_diso2 => disopred_diso2, :postscript_graph => postscript_graph, :psiblast => psiblast }
      end
      if (@job.program_mempack == 1 || @job.program_mempack == 3) 
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :memsat3_data => memsat3_data, :memsat3_image => memsat3_image, :memsatsvm_data => memsatsvm_data, :memsatsvm_image => memsatsvm_image, :memsatsvm_schematic => memsatsvm_schematic, :mempack_cartoon => mempack_cartoon, :graph_results => graph_results, :lipid_results => lipid_results, :contact_results => contact_results}
      end
      if (@job.program_dompred == 1 || @job.program_dompred == 3 )&& @job.program_ffpred == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :dompred_graph => dompred_graph, :dompred_output => dompred_output, :psiblast_output => psiblast_output, :psiblast_table => psiblast_table, :domssea_table => domssea_table, :psipred_ps => psipred_ps}
      end
      if(@job.program_genthreader == 1 || @job.program_genthreader == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :genthreader_data => genthreader_data, :contact_alignment => contact_alignment, :cert_alignment => cert_alignment, :cert_high_alignment => cert_high_alignment, :cert_high_med_alignment => cert_high_med_alignment}
      end
      if (@job.program_bioserf == 1 || @job.program_bioserf == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :mgenthreader_templates => mgenthreader_templates, :psiblast_templates => psiblast_templates, :selected_templates => selected_templates, :model_pdb => model_pdb}
      end
      if (@job.program_mgenthreader == 1 || @job.program_mgenthreader == 3) && @job.program_bioserf == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :genthreader_data => genthreader_data, :contact_alignment => contact_alignment, :cert_alignment => cert_alignment, :cert_high_alignment => cert_high_alignment, :cert_high_med_alignment => cert_high_med_alignment}
      end
      if (@job.program_ffpred == 1 || @job.program_ffpred == 3)
        render :soap => { :message =>  output_message, :job_id => job_id, :state => final_state, :go_table => go_table, :ffpred_data => ffpred_data, :seq_feature_map => seq_feature_map, :transmembrane_diagram => transmembrane_diagram}
      end
      if (@job.program_domthreader == 1 || @job.program_domthreader == 3) && @job.program_domserf == 0
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :domthreader_data => domthreader_data}
      end
      if (@job.program_hspred == 1 || @job.program_hspred == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :annotated_pdb_a => annotated_pdb_a, :annotated_pdb_b => annotated_pdb_b, :hspred_data =>  hspred_data}
      end
      if (@job.program_metsite == 1 || @job.program_metsite == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :annotated_pdb => annotated_pdb, :metsite_data => metsite_data}
      end
      if (@job.program_maketdb == 1 || @job.program_maketdb == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :tdb_file => tdb_file}
      end
      if (@job.program_domserf == 1 || @job.program_domserf == 3)
        render :soap => { :message => output_message, :job_id => job_id, :state => final_state, :alignments => pir_alignments, :pdb_tempaltes => pdb_templates, :domain_templates => domain_templates, :model_pdb => model_pdb}
      end
      
    elsif (job_complete == 2)
      render :soap => { :message => "#{@error_message}", :job_id => job_id, :state => 0, :psipred_postscript => "", :psipred_results => ""}
    elsif (job_complete == 3)
      render :soap => { :message => "There is no job with that ID in the database", :job_id => job_id, :state => 3, :psipred_postscript => "", :psipred_results => ""}
    else
      render :soap => { :message => "This job is still being processed", :job_id => job_id, :state => 2, :psipred_postscript => "", :psipred_results => ""}
    end

  end
end
