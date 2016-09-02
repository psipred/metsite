module GenAlignmentHandler

  require "pp"

     #runs through the alignment data and outputs a fasta formatted multiple alignment file AND a small features table for jalview purposes
  def self.write_gen_alignment (data, name, id, path,object)

    gen_table = ""

    for result in object.request_results.find(:all, :conditions => "status_class = 9 OR status_class = 10")
      gen_table = result.data
    end

    gen_hash = parse_gen_table(gen_table)

    #parse the alignments
    (hit_id, hit_seq, query_id, query_seq, hit_annotation, query_annotation) = parse_gen_alignment(data)
    name_copy = String.new(name)
    ligand_hash = get_ligand_data(name_copy)
    name_copy = String.new(name)
    gaps_hash = get_gaps(name_copy)
    name_copy = String.new(name)
    csa_hash = get_csa(name,ligand_hash)

    #Does the consensus file exist? If not open it and write the header line, then close it.
    puts "writing file : " + path + id.to_s+".cons"
    if ! File.exists?(path + id.to_s + ".cons")
      fhCons = File.open(path + id.to_s + ".cons", 'w')
      fhCons.write("TYPE\tLIGAND\tHIT\tCONF\t\t\t")
      query_seq.each_char do | char |
        if(char =~ /-/)
          next
        end
        fhCons.write(char)
      end
      fhCons.write "\n"
     fhCons.close
    end

    query_length = 0
    #count the number of characters in the sequence
    query_seq.each_char do | char |
       if(char =~ /-/)
          next
        end
        query_length+=1
    end

    name_copy = String.new(name)
    name_copy = name
    chain_id = ""
    if name_copy =~ /.{4}(.)/
      chain_id = $1
    end

    if(gen_hash.has_key? name)
      #open file to put the annotation in
      puts "writing file : " + path + id.to_s+"_"+name+".ann"
      fhAnn = File.open(path + id.to_s + "_"+name+".ann", 'w')
      fhAnn.write("HELIX\tff88ff\nSTRAND\tffee00\nPREDICTED_STRAND\tffee66\nPREDICTED_HELIX\tffaaff\n")

      
      #print out the header rows for the ligand binding residues
      ligand_hash.keys.each do | chain |
        #find data for the same chain as we're talking about
        blue_count = 0
        red_count = 0
        green_count = 0
        cyan_count=0
        #puts "Chain" + chain
        #puts "chain_id" + chain_id
        if(chain.capitalize == chain_id.capitalize)
          #puts "I MADE I HERE!"
          ligand_hash[chain].keys.each do |ligand_name|
              #puts "AND NOW I'M IN HERE!!"
              if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /M/
                fhAnn.write(ligand_name + "\t"+blue_count.to_s(16)+blue_count.to_s(16)+ blue_count.to_s(16)+blue_count.to_s(16))
                fhAnn.write("ff\n")
                blue_count = blue_count+1
              end

              if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /L/
                fhAnn.write(ligand_name + "\tff"+red_count.to_s(16)+red_count.to_s(16)+red_count.to_s(16)+red_count.to_s(16))
                fhAnn.write("\n")
                red_count = red_count+1
              end
              if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /P/
                fhAnn.write(ligand_name + "\t"+green_count.to_s(16)+green_count.to_s(16)+"ff"+green_count.to_s(16)+green_count.to_s(16))
                fhAnn.write("\n")
                green_count = green_count+1
              end
              if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /A/
                fhAnn.write(ligand_name + "\t"+cyan_count.to_s(16)+cyan_count.to_s(16))
                fhAnn.write("ffff\n")
                cyan_count = cyan_count+1
              end
              if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /C/
                fhAnn.write(ligand_name + "\tff9000\n")
                  
              end
          end
        end
      end

      fhAnn.write("\n")
      hConsensusData = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
      #print out the header rows for the ligand binding residues

      ligand_hash.keys.each do | chain |
        #find data for the same chain as we're talking about
        if(chain.capitalize == chain_id.capitalize)
          ligand_hash[chain].keys.each do |ligand_name|
            fhAnn.write("STARTGROUP\thit ligands\n")
              ligand_hash[chain][ligand_name]["LIGAND_CONTACTS"].keys.each do |res_num|
                
                if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /C/
                  res_num = correct_coordinates(res_num,hit_seq,gaps_hash)
                  query_coord = get_query_position(res_num, hit_seq, query_seq)
                  if query_coord != 0
                    hConsensusData["C"][ligand_name][hit_id]["CONF"] = gen_hash[name]
                    hConsensusData["C"][ligand_name][hit_id]["COORDS"][query_coord] = 1
                  end
                  fhAnn.write ligand_name+"\t" + hit_id + "\t-1\t" + res_num.to_s + "\t" + res_num.to_s + "\t"+ligand_name+"\n"
                end

                if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /M/
                  res_num = correct_coordinates(res_num,hit_seq,gaps_hash)
                  query_coord = get_query_position(res_num, hit_seq, query_seq)
                  if query_coord != 0
                    hConsensusData["M"][ligand_name][hit_id]["CONF"] = gen_hash[name]
                    hConsensusData["M"][ligand_name][hit_id]["COORDS"][query_coord] = 1
                  end
                  fhAnn.write ligand_name+"\t" + hit_id + "\t-1\t" + res_num.to_s + "\t" + res_num.to_s + "\t"+ligand_name+"\n"
                end

                if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /L/
                  res_num = correct_coordinates(res_num,hit_seq,gaps_hash)
                  query_coord = get_query_position(res_num, hit_seq, query_seq)
                  
                  if query_coord != 0
                    #puts "query_coord : " + query_coord.to_s
                    hConsensusData["L"][ligand_name][hit_id]["CONF"] = gen_hash[name]
                    hConsensusData["L"][ligand_name][hit_id]["COORDS"][query_coord] = 1
                  end
                  fhAnn.write "Ligand region\t" + hit_id + "\t-1\t" + res_num.to_s + "\t" + res_num.to_s + "\t"+ligand_name+"\n"
                end
                if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /P/
                  res_num = correct_coordinates(res_num,hit_seq,gaps_hash)
                  query_coord = get_query_position(res_num, hit_seq, query_seq)
                  if query_coord != 0
                    hConsensusData["P"][ligand_name][hit_id]["CONF"] = gen_hash[name]
                    hConsensusData["P"][ligand_name][hit_id]["COORDS"][query_coord] = 1
                  end
                  fhAnn.write "Peptide region\t" + hit_id + "\t-1\t" + res_num.to_s + "\t" + res_num.to_s + "\t"+ligand_name+"\n"
                end
                if ligand_hash[chain][ligand_name]["LIGAND_TYPE"] =~ /A/
                  res_num = correct_coordinates(res_num,hit_seq,gaps_hash)
                  query_coord = get_query_position(res_num, hit_seq, query_seq)
                  if query_coord != 0
                    hConsensusData["A"][ligand_name][hit_id]["CONF"] = gen_hash[name]
                    hConsensusData["A"][ligand_name][hit_id]["COORDS"][query_coord] = 1
                  end
                  fhAnn.write "Molecule region\t" + hit_id + "\t-1\t" + res_num.to_s + "\t" + res_num.to_s + "\t"+ligand_name+"\n"
                end
              end
              fhAnn.write("ENDGROUP\thit ligands\n")
          end
        end
      end

      query_copy = String.new(query_seq)
      query_copy.gsub!(/-/, "")
      fhCons = File.open(path + id.to_s + ".cons", 'a')
      #PP::pp(hConsensusData, $stdout, 50)
      hConsensusData.keys.each do |type|
        lig_hash = hConsensusData[type]
        #PP::pp(lig_hash, $stdout, 50)
        lig_hash.keys.each do |lig_name|
          hit_hash = lig_hash[lig_name]
          #PP::pp(hit_hash, $stdout, 50)PP
          hit_hash.keys.each do |hit_id|
            fhCons.write type+"\t"+lig_name+"\t"+hit_id+"\t"+hit_hash[hit_id]["CONF"]+"\t\t\t"
            coords_hash = hit_hash[hit_id]["COORDS"]
            #PP::pp(coords_hash, $stdout, 50)
            #puts "length : " + query_length.to_s
            for k in 1..query_length
              if coords_hash.has_key?(k)
                #puts "found : " + k.to_s
                #puts "residue: " + query_copy[k,1]
                if query_copy[k,1] =~ /-/
                  fhCons.write "0"
                else
                  fhCons.write "1"
                end
              else
               fhCons.write "0"
              end
            end
            fhCons.write "\n"
          end
        end
      end

      fhCons.close

      fhAnn.write("STARTGROUP\thit secondary structure\n")
      hit_annotation.keys.each do | element_number |
        element_hash = hit_annotation[element_number]
        element_hash.keys.each do | ss_type |
          coords_hash = element_hash[ss_type]
          if(ss_type =~ /HELIX/)
            fhAnn.write "Helix region\t" + hit_id + "\t-1\t" + coords_hash["START"].to_s + "\t" + coords_hash["STOP"].to_s + "\tHELIX\n"
          elsif(ss_type =~ /STRAND/)
            fhAnn.write "Strand region\t" + hit_id + "\t-1\t" + coords_hash["START"].to_s + "\t" + coords_hash["STOP"].to_s + "\tSTRAND\n"
          end
        end
      end
      fhAnn.write("ENDGROUP\thit secondary structure\n")

      fhAnn.write("STARTGROUP\tquery secondary structure\n")
      query_annotation.keys.each do | element_number |
        element_hash = query_annotation[element_number]
        element_hash.keys.each do | ss_type |
          coords_hash = element_hash[ss_type]
          if(ss_type =~ /HELIX/)
            fhAnn.write "Helix region\t" + query_id + "\t-1\t" + coords_hash["START"].to_s + "\t" + coords_hash["STOP"].to_s + "\tPREDICTED_HELIX\n"
          elsif(ss_type =~ /STRAND/)
            fhAnn.write "Strand region\t" + query_id + "\t-1\t" + coords_hash["START"].to_s + "\t" + coords_hash["STOP"].to_s + "\tPREDICTED_STRAND\n"
          end
        end
      end
      fhAnn.write("ENDGROUP\tquery secondary structure\n")
      fhAnn.close

      #open file to put the alignment in
      #don't write the second or subsequent shorter alignments if pGenTHREADER has output them
      if ! File.exists?(path+id.to_s+"_"+name+".aln")
         puts "writing file : " + path+id.to_s+"_"+name+".aln"
      fhAln = File.open(path+id.to_s+"_"+name+".aln", 'w')

      fhAln.write(">" + hit_id +"\n")
      fhAln.write(hit_seq + "\n")
      fhAln.write(">" + query_id + "\n")
      fhAln.write(query_seq + "\n")
      fhAln.close

      end

    end
  end

 def self.get_csa(name_csa, ligand_hash)

    csa_file = String.new("/webdata/data/current/csa/CSA.dat")
  	pdb = String.new()
    chain_id = String.new()
    if name_csa =~ /^(.{4})(.)/
      pdb = $1
      chain_id = $2
    end
   
   command =  "grep '"+pdb+".\\{7\\}"+chain_id.capitalize+"' "+csa_file
   #puts "command :"+command
   lines = `#{command}`
   #puts lines
  
   results_lines = lines.split(/\n/)
   results_lines.each do |line|
   	 if line =~ /.{4},\d+,(.{3}),.{1},(\d+),/
   	 	ligand_hash[chain_id]["CAT_SITE"]["LIGAND_TYPE"] = "C"
		ligand_hash[chain_id]["CAT_SITE"]["LIGAND_CONTACTS"][$2]["NAME"] = $1
	 	ligand_hash[chain_id]["CAT_SITE"]["LIGAND_CONTACTS"][$2]["INTERACTIONS"][1] = 1
		
     end
   end
   return ligand_hash

 end

  #takes a residue position in the hit_seq and works out which position in the query seq it is
  def self.get_query_position(res_num, hit_seq, query_seq)

    hit_coord = 0
    hit_residue_count = 0
    hit_seq.each_char do |character|
        hit_coord+=1
        if character !~ /-/
          hit_residue_count+=1
        end
        if hit_residue_count == res_num
          break
        end
    end

    query_coord = 0
    residue_count = 0
    query_seq.each_char do |character|
        query_coord+=1
        if character !~ /-/
          residue_count+=1
        end
        if hit_coord == query_coord
          break
        end
    end

    if query_seq[hit_coord-1,1].to_s =~ /-/
      #puts "0 : Hit res: "+hit_seq[hit_coord-1,1].to_s+"  Query res: "+query_seq[hit_coord-1,1].to_s
      return 0
    else
      #puts residue_count.to_s + "Hit res: "+hit_seq[hit_coord-1,1].to_s+"  Query res: "+query_seq[hit_coord-1,1].to_s
      return residue_count
    end
  end

  #adjust coordinates to correct for insertions so that jalview will place the features in the correct place
  def self.correct_coordinates(residue_number, hit_sequence, gaps)

    dash_count = 0
    seq_count = 0
    coord = residue_number.to_i()
    hit_sequence.each_char do |character|
      #puts character
      if(character =~ /-/)
        dash_count+=1
      end
      if(character =~ /[a-zA-Z]/)
        seq_count+=1
      end

      if seq_count == residue_number.to_i()
        #puts seq_count.to_s
        #puts residue_number.to_s
        break
      end

    end

    gap_adjust = 0
    gaps.keys.each do |counter|
      if gaps[counter]["START"] < residue_number.to_i()
          gap_adjust+=gaps[counter]["LENGTH"].to_i
      end
    end

    #puts "coord: " +coord.to_s
    #puts "dash_count: "+dash_count.to_s
    #coord = coord-dash_count
    coord = coord-gap_adjust
    #puts "coord adjust: " +coord.to_s
    return coord
  end

  def self.get_gaps(name_lig)

    chain_id = String.new()
    if name_lig =~ /^.{4}(.)/
      chain_id = $1
    end

    name_lig.chop!
    if(name_lig.length == 5)
      name_lig.chop!
    end

    uri = URI.parse("http://www.ebi.ac.uk/thornton-srv/databases/pdbsum/" + name_lig + "/" +name_lig+"_"+ chain_id.capitalize + ".csq")

    # Shortcut
    response = Net::HTTP.get_response(uri)
    lines = response.body.split(/\n/)
    gaps = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }

    seq_start = 1
    gap_count = 0
    gap_length = 0
    lines.each do |line|
      if line =~ /(\d+)\s+(\d+)/
        start = $1.to_i
        length = $2.to_i

        if(start > seq_start)
          gap_length = start-seq_start
          gap_count+=1
        end

        gaps[gap_count]["LENGTH"] = gap_length
        gaps[gap_count]["START"] = seq_start
        gaps[gap_count]["STOP"] = start-1
        #puts "length " + gap_length.to_s
        #puts "start " + seq_start.to_s
        #puts "stop " +gaps[gap_count]["STOP"].to_s
        seq_start=length+start
      end
    end

    return gaps
  end

  def self.get_ligand_data(name_lig)

    name_lig.chop!
    if(name_lig.length == 5)
      name_lig.chop!
    end

    uri = URI.parse("http://www.ebi.ac.uk/thornton-srv/databases/pdbsum/" + name_lig + "/grow.out")

    # Shortcut
    response = Net::HTTP.get_response(uri)

    lines = response.body.split(/\n/)
    #annotation_data = Hash.new{ |h,k | h[k] = Hash.new{ |h2, k2| h2[k2] = hash.new(0)} }
    annotation_data = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }

    amino_acids = {'ALA'=>1,'ARG'=>1, 'ASN'=>1, 'ASP' => 1, 'ASX' => 1,
      'CYS' => 1, 'GLU' => 1, 'GLN' => 1, 'GLX' => 1, 'GLY' => 1,
      'HIS' => 1, 'ILE' => 1, 'LEU' => 1, 'LYS' => 1, 'MET' => 1,
      'PHE' => 1, 'PRO' => 1, 'SER' => 1, 'THR' => 1, 'TRY' => 1,
      'TYR' => 1, 'VAL' => 1}

    interaction_count=1

    lines.each do |line|
      #would be better as a scanf
      if line =~ /(.{2}).{2}(.{2})(.{1})(.{7})(.{3}).{8}.{12}.{7}(.{3})(.{7})(.{1})(.{6})(.+)/
        bond = $1
        ligand = $2
        chain_id = $3
        residue_number = $4
        residue_name = $5

        ligand_name = $6
        ligand_number = $7
        ligand_chain = $8

        distance = $9

        bond = bond.gsub(/\s+/, "")
        ligand = ligand.gsub(/\s+/, "")
        chain_id = chain_id.gsub(/\s+/, "")
        residue_number = residue_number.gsub(/\s+/, "")
        residue_name = residue_name.gsub(/\s+/, "")
        ligand_name = ligand_name.gsub(/\s+/, "")
        ligand_number = ligand_number.gsub(/\s+/, "")
        ligand_chain = ligand_chain.gsub(/\s+/, "")
        distance = distance.gsub(/\s+/, "")
        #puts chain_id+" "+distance

        if amino_acids.has_key?(ligand_name)
          ligand = "P"
        end

        if ligand =~ /P/
          ligand_name = "PEPTIDE_"+ligand_chain
        end

        annotation_data[chain_id][ligand_name]["LIGAND_TYPE"] = ligand
        if annotation_data[chain_id][ligand_name]["LIGAND_CONTACTS"].has_key?(residue_number)
          interaction_count = 1
          annotation_data[chain_id][ligand_name]["LIGAND_CONTACTS"][residue_number]["INTERACTIONS"].keys.each do | count |
            if count > interaction_count
              interaction_count = count
            end
          end
          interaction_count = interaction_count + 1
        else
          interaction_count = 1
        end

        annotation_data[chain_id][ligand_name]["LIGAND_CONTACTS"][residue_number]["NAME"] = residue_name
        annotation_data[chain_id][ligand_name]["LIGAND_CONTACTS"][residue_number]["INTERACTIONS"][interaction_count] = ligand_number


      end
    end

    return annotation_data

  end

  #Gets the list of MEDIUM or better pdb IDs
  def self.parse_gen_table(gen_data)
    results_lines = gen_data.split(/\n/)
    results_data = Hash.new(0)

    results_lines.each do |line|

      tokens = line.split(/\s+/)
      #puts tokens.length.to_s

      if(tokens[0] !~ /GUESS|LOW/)
        if(tokens.length == 10)
          key = tokens[9]
          results_data[key] = tokens[0]
        end

       if(tokens.length == 12)
         key = tokens[11]
         results_data[key] = tokens[0]
       end

      end
    end

    return(results_data)

  end

  def self.parse_gen_alignment(data)
    temp_data = data.gsub(/>>>\sAlignment\swith\s.{6,7}:\s/, "")
    alignment_segments = temp_data.split(/\n{3}/)
    query_id = ''
    query_seq = ''
    hit_id = ''
    hit_seq = ''
    hit_annotation = Hash.new(0)
    query_annotation = Hash.new(0)
    hit_seq_count = 0
    query_seq_count = 0
    previous_hit_character = "Z"
    previous_query_character = "Z"
    hit_element_count = 0
    query_element_count = 0

    alignment_segments.each_with_index do |segment, index|
        lines_temp = []
        lines_temp = segment.split(/\n/)
        lines = []
        #puts "SEGMENT:\n"+segment+"\n"

      lines_temp.each do |line|
        if line.length > 0
          lines.push(line)
        end
      end

      lines.each_with_index do |line, index2|
              line.chomp

            #puts "LINE:"+line+"\n"

            #reading the hit's secondary structure
              if(index2 == 1)
                characters = line.split("")

                characters.each_with_index do |character, index3|
                  if(index3 < 9)
                    next
                  end

                  $hit_type = ''
                  if character.include? "E"
                    $hit_type = "STRAND"
                  elsif character.include? "H"
                    $hit_type = "HELIX"
                  elsif character.include? "-"
                    $hit_type = "GAP"
                    next
                  else
                    $hit_type = "COIL"
                  end

                  hit_seq_count = hit_seq_count+1
                  if(hit_seq_count == 1)
                    previous_hit_character=character
                    location_hash = Hash.new(0)
                    element_hash = Hash.new(0)
                    location_hash["START"] = 1
                    location_hash["STOP"] = 1
                    element_hash[$hit_type] = location_hash
                    hit_annotation[hit_element_count] = element_hash
                  else
                    if previous_hit_character.include? character
                      #puts "BITS:"+ hit_element_count.to_s + " : " + $hit_type.to_s
                      hit_annotation[hit_element_count][$hit_type]["STOP"] = hit_seq_count
                    end

                    if ! previous_hit_character.include? character
                      hit_element_count = hit_element_count+1
                      previous_hit_character = character
                      location_hash = Hash.new(0)
                      element_hash = Hash.new(0)
                      location_hash["START"] = hit_seq_count
                      location_hash["STOP"] = hit_seq_count
                      element_hash[$hit_type] = location_hash
                      hit_annotation[hit_element_count] = element_hash
                    end
                  end


                end

              end

              #redaing the query's secondary structure
              if(index2 == 5)
                #skip if this is a ruler line and not a secondary structure annotation line
                if(line !~ /C|H|E|-/)
                  next
                end
                characters = line.split("")

                characters.each_with_index do |character, index3|
                  if(index3 < 9)
                    next
                  end

                  $query_type = ''
                  if character.include? "E"
                    $query_type = "STRAND"
                  elsif character.include? "H"
                    $query_type = "HELIX"
                  elsif character.include? "-"
                    $query_type = "GAP"
                    next
                  else
                    $query_type = "COIL"
                  end

                  query_seq_count = query_seq_count+1
                  if(query_seq_count == 1)
                    previous_query_character=character
                    location_hash = Hash.new(0)
                    element_hash = Hash.new(0)
                    location_hash["START"] = 1
                    location_hash["STOP"] = 1
                    element_hash[$query_type] = location_hash
                    query_annotation[query_element_count] = element_hash
                  else
                    if previous_query_character.include? character
                      #puts "QBITS:"+ query_element_count.to_s + " : " + $hit_type.to_s
                      query_annotation[query_element_count][$query_type]["STOP"] = query_seq_count
                    end

                    if ! previous_query_character.include? character
                      query_element_count = query_element_count+1
                      previous_query_character = character
                      location_hash = Hash.new(0)
                      element_hash = Hash.new(0)
                      location_hash["START"] = query_seq_count
                      location_hash["STOP"] = query_seq_count
                      element_hash[$query_type] = location_hash
                      query_annotation[query_element_count] = element_hash
                    end
                  end


                end

              end

              #reading the hit's sequence
              if(index2 == 2)
                parts = line.split(/\s+/)
                hit_id = parts[0]
                #puts line +"\n"
                if ! parts[1].nil?
                  hit_seq = hit_seq + parts[1]
                end
              end

             #reading the query's sequence
             if(index2 == 4)
               parts = line.split(/\s+/)
                query_id = parts[0]
                if ! parts[1].nil?
                  query_seq = query_seq + parts[1]
                end
             end

         end
     end


    return hit_id, hit_seq, query_id, query_seq, hit_annotation, query_annotation
  end

end