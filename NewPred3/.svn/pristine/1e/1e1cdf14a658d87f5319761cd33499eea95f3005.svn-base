class JobValidator < ActiveModel::Validator

    require "unicode_utils/upcase"

    def validate(record)

    @invalid = 0
    @sequences_ok = 1
    @first_length = 0
    @longest_length = 0
    @count_seqs = 0
    @ndna = 0
    @found_seqs = 0

    if(record.Type =~ /seqJob/)
      @count_seqs = record.QueryString.to_s.count('>')

      if(@count_seqs > 1)
        #we're dealing with an MSA, so we do some handy calculations
        alignment_lines = record.QueryString.to_s.split(/\n/)
        alignment_lines.each do |line|
          if(line !~ /^>/)
            @ndna = line.to_s.count "ATCGUNatcgun"
            if(line.to_s.gsub(/\n|\s/, "") =~ /[^ACDEFGHIKLMNPQRSTVWYX_-]+/i)
              @invalid = 1
            end
          else
            @found_seqs+=1
          end
        end

        sequences = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc)}
        if @count_seqs > 1
          alignment_lines = record.QueryString.to_s.split(/\n/)

          seq_count = 0
          alignment_lines.each do |line|
            line = line.gsub(/\n|\s/, "")
            line = UnicodeUtils.upcase(line)

            if(line =~ /^>/)
              seq_count+=1
            else
              if sequences[seq_count].has_key?("SEQ")
                sequences[seq_count]["SEQ"] = sequences[seq_count]["SEQ"] + line
              else
                sequences[seq_count]["SEQ"] = line
              end
              #sequences[seq_count]["SEQ"] = sequences[seq_count]["SEQ"] + line
              sequences[seq_count]["LENGTH"] = sequences[seq_count]["SEQ"].to_s.length

            end
          end

          sequences.keys.each do |seq_id|
            #if there is no sequence for this one decrement the found sequences counter
            if sequences[seq_id]["SEQ"].to_s.length == 0
              @found_seqs -=1
            end

            #check we're not looking at nucletide or invalid characters
            @ndna = sequences[seq_id]["SEQ"].to_s.count "ATCGUNatcgun"
            if (@ndna > (0.95 * sequences[seq_id]["LENGTH"])) && sequences[seq_id]["LENGTH"] > 10
                record.errors.add(:address, "In the MSA sequence "+seq_id.to_s+"  appears to contain nucleotide sequence. This service requires protein sequence as input")
              end
            if(sequences[seq_id]["SEQ"].to_s.gsub(/\n|\s/, "") =~ /[^ACDEFGHIKLMNPQRSTVWYX_-]+/i)
                @invalid = 1
              end

            #testing the lengths match
            if @first_length == 0
              @first_length = sequences[seq_id]["LENGTH"]
              @longest_length = sequences[seq_id]["LENGTH"]
            else
              if(@first_length != sequences[seq_id]["LENGTH"])
                @sequences_ok = 0
              end
              if(sequences[seq_id]["LENGTH"] > @longest_length)
                @longest_length = sequences[seq_id]["LENGTH"]
              end
            end
          end


        end

        #calculations in hand we throw the appropriate errors
        if(@found_seqs != @count_seqs)
          record.errors.add(:QueryString, "Your MSA does not appear to be formatted correctly")
        end

        if @invalid == 1
          record.errors.add(:QueryString, "Your MSA contains invalid characters")
        end

        if(@sequences_ok == 0)
          record.errors.add(:QueryString, "Sequences in the MSA are not of equal length. Ensure your input is a correctly formatted Multiple Sequence Alignment")
        end

         if (record.program_svmmemsat == 1 || record.program_mempack == 1 || record.program_genthreader == 1 || record.program_ffpred == 1)
           record.errors.add(:QueryString, "MSA input is not available for genTHREADER, FFPred, MEMSATSVM or MEMPACK")
         end

        #too long errors
        if (record.program_mgenthreader == 1 || record.program_genthreader == 1 || record.program_domthreader == 1 || record.Type =~ /FragFold/)  && @longest_length > 1000
          record.errors.add(:QueryString, "Your MSA is too long for pDomThREADER, genTHREADER or pGenTHREADER to process. Please consider dividing it up into likely domains and submitting each domain sequence separately. You might find our DomPred service useful for this.")
        end
        if record.program_dompred == 1 &&  @longest_length > 3000
          record.errors.add(:QueryString, "Your MSA is too long for Dompred to process.")
        end
        if record.program_bioserf == 1 && @longest_length > 1500
          record.errors.add(:QueryString, "Your MSA is too long (>1,500 residues), for BioSerf2 to process. Please consider dividing your sequence into likely domains or subsequences. You might find our DomPred service useful for this.")
        end
        if (record.program_psipred == 1 || record.program_svmmemsat == 1 || record.program_mempack == 1 || record.program_disopred == 1 || record.program_ffpred == 1  ) && @longest_length > 1500
          record.errors.add(:QueryString, "Your MSA is too long (>1,500 residues) for the server to process. Please consider dividing it up into likely domains and submitting each domain sequence separately. You might find our DomPred service useful for this.")
        end

        #too short errors
        if(@longest_length  < 10  &&  (record.program_psipred == 1 || record.program_mgenthreader == 1 || record.program_genthreader == 1 || record.program_domthreader == 1 || record.program_ffpred ==1))
        record.errors.add(:QueryString, "Your sequence is too short to process.")
      end
      if(@longest_length   < 120 && record.program_dompred == 1)
        record.errors.add(:QueryString, "Your sequence is too short for dompred to process.")
      end
      #if(@longest_length  < 30 && (record.program_svmmemsat == 1 || record.program_svmmemsat ==1 || record.program_mempack == 1))
      if(@longest_length  < 30 && (record.program_svmmemsat == 1 || record.program_mempack == 1))
        record.errors.add(:QueryString, "Your sequence is too short for MEMSATSVM or MEMPACK to process.")
      end

      else
        #we're dealing with a single sequence
        @found_seqs = 1
        @count_seqs = 1

        #Test here for invalid characters
        unless record.QueryString.blank? then
        end
        @ndna = record.QueryString.to_s.count "ATCGUNatcgun"
        if record.QueryString.to_s.gsub(/\n|\s/, "") =~ /[^ACDEFGHIKLMNPQRSTVWYX_-]+/i
          @invalid = 1
        end

        if @invalid == 1
          record.errors.add(:QueryString, "Your sequence contains invalid characters \n" + record.QueryString.to_s)
      	end

        #sequence too long errors
        if (record.program_mgenthreader == 1 || record.program_genthreader == 1 || record.program_domthreader == 1 || record.Type =~ /FragFold/)  && record.QueryString.to_s.length > 1000
          record.errors.add(:QueryString, "Your sequence is too long for pDomThREADER, genTHREADER or pGenTHREADER to process. Please consider dividing it up into likely domains and submitting each domain sequence separately. You might find our DomPred service useful for this.")
        end
        if (record.program_psipred == 1 && record.program_dompred == 0) && record.QueryString.to_s.length > 1500
          record.errors.add(:QueryString, "Your sequence is too long (>1,500 residues) for the server to process. Please consider dividing it up into likely domains and submitting each domain sequence separately. You might find our DomPred service useful for this.")
        end
        if (record.program_svmmemsat == 1 || record.program_mempack == 1 || record.program_disopred == 1 || record.program_ffpred == 1 ) && record.QueryString.to_s.length > 1500
          record.errors.add(:QueryString, "Your sequence is too long (>1,500 residues) for the server to process. Please consider dividing it up into likely domains and submitting each domain sequence separately. You might find our DomPred service useful for this.")
        end
        if record.program_bioserf == 1 && record.QueryString.to_s.length > 1500
          record.errors.add(:QueryString, "Your sequence is too long (>1,500 residues), for BioSerf2 to process. Please consider dividing your sequence into likely domains or subsequences. You might find our DomPred service useful for this.")
        end
        if record.program_dompred == 1 &&  record.QueryString.to_s.length > 3000
          record.errors.add(:QueryString, "Your sequence is too long for Dompred to process.")
        end


        #sequence too short errors
        #reject sequences that are too short.
      if(record.QueryString.to_s.length < 10  &&  (record.program_psipred == 1 || record.program_mgenthreader == 1 || record.program_genthreader == 1 || record.program_domthreader == 1 || record.program_ffpred ==1))
        record.errors.add(:QueryString, "Your sequence is too short to process.")
      end
      if(record.QueryString.to_s.length  < 120 && record.program_dompred == 1)
        record.errors.add(:QueryString, "Your sequence is too short for dompred to process.")
      end
      if(record.QueryString.to_s.length < 30 && (record.program_svmmemsat == 1 || record.program_mempack == 1))
        record.errors.add(:QueryString, "Your sequence is too short for MEMSATSVM or MEMPACK to process.")
      end

      #nucleotide error
      if (@ndna > (0.95 * record.QueryString.to_s.length)) && record.QueryString.to_s.length > 10
        record.errors.add(:address, "Your sequence appears to be nucleotide sequence. This service requires protein sequence as input")
      end

      end

    elsif (record.Type =~ /structJob/)

      #TODO: one day we should let these services take xml pdb files
      if(record.QueryString.to_s !~ /^HEADER|^ATOM\s+\d+/i && (record.program_metsite || record.program_hspred || record.program_maketdb))
        record.errors.add(:QueryString, "Your file does not look like a plain text ascii pdb file. This service does not accept .gz or xml format pdb files")
      end
    
      

      #TODO: get rid of check_chains.pl at the backend and do the PDB file validations here

    end

    #Don't validate the address unless it's given
    unless record.address.blank? then
      #reject request from people using freemail addresses
      #  if record.address.to_s =~ /@.*(yahoo|gmail|googlemail|lycos|wanadoo|hotmail|t-online|tiscali|fastwebnet|mailme|free)\.[a-z]{3,3}?\z/
      #   record.errors.add(:address, "Sorry! Free e-mail addresses such as yahoo or hotmail may not be used to access our servers.\nNOTE: We can not make exceptions to this.\n")
      # end

      #reject requests from commercial email addresses
      #if record.address.to_s =~ /(\.co\.[a-z][a-z]|\.com\.[a-z][a-z]|\.net\.[a-z][a-z]|\.com|\.net|\.firm|\.store|\.ltd\.uk|\.plc\.uk|\.tm|fr\.fm|fr\.st|fr\.vu|euro\.st|be\.tf|best\.cd|it\.st|int\.ms|ht\.st|gr\.st|com4\.ws|clan\.st|ca\.tc|c0m\.st|chiron\.|msi\.|web\.de)\z/i
      #  record.errors.add(:address, "Sorry! Access from commercial domains is not possible without using a valid password.\nIf you are a non-academic user, we can offer paid-for priority access to our services. Please visit <a href=\"http://www.ebisu.co.uk/Software_%26_Databases.html\">Ebisu</a> for further details.")
      #end

      #bounce everthing from the .gr.xx domain unless that valid password is given.  This is where we allow people with valid passwords
      # note the use of a global variable - naughty naughty, very naughty
      if $passwd !~ /\APSI-895\z/ && record.address.to_s =~ /\.gr\.[a-z][a-z]\z/
        record.errors.add(:address, "Sorry! Access from commercial domains is not possible without using a valid password.\nIf you are a non-academic user, we can offer paid-for priority access to our services. Please visit <a href=\"http://www.ebisu.co.uk/Software_%26_Databases.html\">Ebisu</a> for further details. ")
      end

    end

    end

end