module EmailHandler

  def self.handle_email(job_status,newstatus, logger, psiblast_switch, path, object)
    
        if (job_status.status_class == 2)
        newstatus.status_class = job_status.status_class
        newstatus.status = job_status.status
        object.state = job_status.status_code
        object.save!

        # end processing on completion as well
        if (job_status.status_code == 4)
          @end_poll = true
        end

        #don't yet throw emails for the normal services
        if (object.Type !~ /seqJob|structJob|mgenthreader|genthreader|psipred|metsite|dompred|disopred|memsat|domthreader|svmmemsat|hspred|mempack|ffpred|maketdb/ && (job_status.status_code == 4) && (!object.address.nil?)) # job finished
          # since just completed, and e-mail is registered, send models out...
          models = object.get_models
          for model in models
            JobMailer.completion(object, model)
          end
        end

        #seqJob job delivery email!!! for now just returning the psipred results. Will have to think this through
        #TODO: Fix job delivery email to be more meaningful when returning multiple analyses
        if (object.Type =~ /seqJob/ && (job_status.status_code == 4) && (!object.address.nil?) && (object.address.length > 5)) # job finished
          #  # since just completed, and e-mail is registered, send models out...
          psipred_results = object.get_result(11)
            email_body = "Your PSIPRED Sequence Workbench job is complete. You can view the results and download files at:\r\n\r\n http://bioinf.cs.ucl.ac.uk/psipred/result/#{object.UUID} \r\n\r\n"

			 notsent = true
            errors = 0
            while (notsent)
              begin
			  	puts "Sending email to: " + object.address
				JobMailer.newpsi(object, email_body).deliver
                notsent = false
              rescue Exception => e
                errors = errors + 1
                if errors > 4
                  puts "Failed to send psipred email: SMTP error " + e.to_s
                  notsent = false
                end
              rescue Timeout::Error => e
                errors = errors + 1
                if errors > 4
                  puts "Failed to send psipred email: TimeOut" + e.to_s
                  notsent = false
                end
              end
            end

        end

      #seqJob job delivery email!!! for now just returning the psipred results. Will have to think this through
        #TODO: Fix job delivery email to be more meaningful when returning multiple analyses
        if (object.Type =~ /structJob/ && (job_status.status_code == 4) && (!object.address.nil?) && (object.address.length > 5)) # job finished
          #  # since just completed, and e-mail is registered, send models out...
          #puts "hi there"
          psipred_results = object.get_result(11)
          email_body = "Your PSIPRED Structure Workbench job is complete. You can view the results and download files at:\r\n\r\n http://bioinf.cs.ucl.ac.uk/structure/result/#{object.UUID} \r\n\r\n"


            notsent = true
            errors = 0
            while (notsent)
              begin
                #puts "we made it to email"
                puts "Sending email to: " + object.address
                JobMailer.struct(object, email_body).deliver
                notsent = false
              rescue Exception => e
                errors = errors + 1
                if errors > 4
                  puts "Failed to send psipred email: SMTP error"
                  notsent = false
                end
              rescue Timeout::Error => e
                errors = errors + 1
                if errors > 4
                  puts "Failed to send psipred email"
                  notsent = false
                end
              end
            end

        end


        #Check if expansion job (FF opt etc)
        expansion = object.ff_expansion
        if ((job_status.status_code == 4) && !expansion.nil? && (object.Type =~ /^BioSerf$/ || object.Type =~ /^GenJobFN$/))
          # need to create the expansion array now
          ff_input = object.request_results.find(:first, :conditions => {:status => "FragFold Input File", :status_class => 4})
          paramsets = expansion.values.split("\n")
          keys = expansion.overrides.split("\n")
          expansionset = Array.new
          for paramset in paramsets

            values = paramset.split(",")
            expandedjob = Job.new()
            expandedjob.ff_expansion = expansion
            expandedjob.QueryString = ff_input.data
            expandedjob.Type = "FragFold"
            newname = object.name.gsub("_ref", "")
            for value in values
              newname = "#{newname}_#{value.to_s.rjust(4, "0")}"
            end
            expandedjob.name = newname

            expandedjob.user_id = object.user_id

            # set config from drop down selection
            expandedjob.configuration_id = object.configuration_id

            expandedjob.ip = object.ip
            expandedjob.address = object.address

            expandedjob.save!

            keys.each_with_index { |key, i|
              override = JobConfigOverride.create
              override.job_id = expandedjob.id
              override.key = key.strip
              override.value = values.at(i)
              override.save!
            }

            expansionset << expandedjob
          end
          logger.info("Expanding #{expansionset.length} jobs on #{object.name}")
          object.submit_jobs(expansionset)
        end

        # if job just completed, and it was a test harness run...
        # create the appropriate test_model entries for the test harness
        cur_run = object.pending_runs
        if ((job_status.status_code == 4) && (cur_run.length > 0))
          cur_run = cur_run.first
          models = object.get_models
          entry_id = object.name.split("_").last
          model_type = ModelType.find_by_name(cur_run.name)
          model_type = ModelType.create(:name => cur_run.name) if model_type.nil?

          logger.info("found #{models.length} final models for #{entry_id}")
          for this_model in models
            test_model = TestModel.create()
            test_model.pdb = this_model
            test_model.model_type = model_type
            test_model.test_entry_id = entry_id
            test_model.job_id = object.id
            test_model.save!
          end

          models = object.get_alternate_models
          if (!models.nil?)
            logger.info("found #{models.length} alternate models for #{entry_id}")
            for alt_model in models
              test_model = TestModel.create()
              test_model.pdb = alt_model
              test_model.model_type = model_type
              test_model.test_entry_id = entry_id
              test_model.job_id = object.id
              test_model.save!
            end
          end

        end

        if ((job_status.status_code == 3)) # job failed
          # since just completed, and e-mail is registered, send models out...
          #JobMailer.failure(object) if !object.address.nil?
          @end_poll = true
        end
      end
  end

end
