module FfpredDataProcessor
  
  require "dbi"
  
  def set_aanorm
  hAA_norm = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  hAA_norm["A"]["val"]=0.071783248006309
  hAA_norm["A"]["sde"]=0.027367661524275
  hAA_norm["V"]["val"]=0.059624595369901
  hAA_norm["V"]["sde"]=0.020377791528745
  hAA_norm["Y"]["val"]=0.026075068240437
  hAA_norm["Y"]["sde"]=0.014822471531379
  hAA_norm["W"]["val"]=0.014166002612771
  hAA_norm["W"]["sde"]=0.010471835801996
  hAA_norm["T"]["val"]=0.052593582972714
  hAA_norm["T"]["sde"]=0.020094793964597
  hAA_norm["S"]["val"]=0.082123241332099
  hAA_norm["S"]["sde"]=0.028687566081512
  hAA_norm["P"]["val"]=0.065557531322241
  hAA_norm["P"]["sde"]=0.034239398496736
  hAA_norm["F"]["val"]=0.037103994969002
  hAA_norm["F"]["sde"]=0.018543423139186
  hAA_norm["M"]["val"]=0.022562818183955
  hAA_norm["M"]["sde"]=0.011321039662481
  hAA_norm["K"]["val"]=0.054833979269185
  hAA_norm["K"]["sde"]=0.029264083667157
  hAA_norm["L"]["val"]=0.10010591575906
  hAA_norm["L"]["sde"]=0.030276808519009
  hAA_norm["I"]["val"]=0.042034526040467
  hAA_norm["I"]["sde"]=0.020826849262495
  hAA_norm["H"]["val"]=0.027141403537598
  hAA_norm["H"]["sde"]=0.01550566378985
  hAA_norm["G"]["val"]=0.069179820104536
  hAA_norm["G"]["sde"]=0.030087562057328
  hAA_norm["Q"]["val"]=0.065920561931801
  hAA_norm["Q"]["sde"]=0.030103091008366
  hAA_norm["E"]["val"]=0.04647846225838
  hAA_norm["E"]["sde"]=0.019946269461736
  hAA_norm["C"]["val"]=0.024908551872056
  hAA_norm["C"]["sde"]=0.020822909589504
  hAA_norm["D"]["val"]=0.044337904726041
  hAA_norm["D"]["sde"]=0.018436677256726
  hAA_norm["N"]["val"]=0.033507020987033
  hAA_norm["N"]["sde"]=0.016536022288204
  hAA_norm["R"]["val"]=0.05974046903119
  hAA_norm["R"]["sde"]=0.025165994773384
  return hAA_norm
  end

  def set_fnorm
  hF_norm = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  hF_norm['hydrophobicity']["val"]=-0.34876828080152
  hF_norm['hydrophobicity']["sde"]=0.75559152769799;
  hF_norm['percent positive residues']["val"]=11.457717466948
  hF_norm['percent positive residues']["sde"]=3.567133341139
  hF_norm['aliphatic index']["val"]=79.911549319099
  hF_norm['aliphatic index']["sde"]=16.787617978827
  hF_norm['isoelectric point']["val"]=7.6102046383603
  hF_norm['isoelectric point']["sde"]=1.9716111020088
  hF_norm['molecular weight']["val"]=48668.412839961
  hF_norm['molecular weight']["sde"]=37838.324895969
  hF_norm['charge']["val"]=5.0991763057604
  hF_norm['charge']["sde"]=16.83863659025
  hF_norm['percent negative residues']["val"]=11.026190128176
  hF_norm['percent negative residues']["sde"]=4.0206631680926
  hF_norm['molar extinction coefficient']["val"]=46475.293923926
  hF_norm['molar extinction coefficient']["sde"]=39299.399848823
  return hF_norm
  end

  def get_go(job_state)
    
    hData = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
     for line in job_state.data.split(/\n/)
       if line =~ /^#/
         next
       end
       entries = Array.new()
       entries = line.split(/\t/)
       entries[1] = entries[1].gsub(/GO:/, "")
       
      #hData[entries[0]]["score"] = entries[0]
      #hData[entries[0]]["id"] = entries[1]
      #hData[entries[0]]["safe"] = entries[2]
      #hData[entries[0]]["domain"] = entries[3]
      #hData[entries[0]]["desc"] = entries[4]
      hData[entries[1]]["score"] = entries[0]
      hData[entries[1]]["id"] = entries[1]
      hData[entries[1]]["rl"] = entries[2]
      hData[entries[1]]["domain"] = entries[3]
      hData[entries[1]]["desc"] = entries[4]

    end
     return(hData)
   end

   def get_data(hObj, job_state)
    line_count = 0
    hF_norm =set_fnorm()
    hAA_norm=set_aanorm()
    for line in job_state.data.split(/\n/)
      line_count+=1
      if line_count == 1
        #first line is description and aa seq
         entries = Array.new()
         entries = line.split(/\t/)
         entries[1].gsub!(/\s+/,"")

        hObj["LEN"] = entries[1].length()
        hObj["len"] = entries[1].length()
        hObj["aa_seq"] = entries[1]
        hObj["seq"] = format_seq(entries[1])
        entries[0].gsub!(/\>/,"")
        hObj["desc"] = entries[0]
        hObj["TM_TOPOL"]="";
      else
         aLine = Array.new()
         aLine = line.split(/\t/)
         if((aLine.length() == 5) && (aLine[0] !~ /^SP/))
          #my ($name,$type,$from,$to,$score) = @tmp;

           i = hObj.has_key?(aLine[0]) ? hObj[aLine[0]].keys().length() : 0

          hObj[aLine[0]][i]["from"] = aLine[2];
          hObj[aLine[0]][i]["to"] = aLine[3];
          hObj[aLine[0]][i]["val"] = aLine[4];
          hObj[aLine[0]][i]["name"] = aLine[0];
          hObj[aLine[0]][i]["type"] = aLine[1];

          hObj["GG"][i] = hObj[aLine[0]][i] if aLine[0] =~ /[ON]G/

          
          if aLine[0] =~ /TM/
            hObj["TM_TOPOL"]+= i.to_s+"\."+aLine[2]+"\,"+aLine[3]+"\;"
          end
        elsif(aLine.length() < 5)
            #psort results
            #my ($name, $feat,$val,$score) = @tmp;
            #hObj[aLine[0]][aLine[1]][aLine[2]] = printf "%.2f", aLine[2]
            #hObj[aLine[0]][aLine[1]]["col"] = get_aa_color( (aLine[2].to_i-hF_norm[aLine[1]]["val"]).to_i / hF_norm[aLine[1]]["sde"]).to_i if aLine[0]=~/SF/
           
            if(aLine[0] =~ /^AA/)
             
             hObj[aLine[0]][aLine[1]]["val"] = sprintf "%.2f",aLine[2].to_f*100
             hObj[aLine[0]][aLine[1]]["col"] = get_aa_color((aLine[2].to_f-hAA_norm[aLine[1]]["val"].to_f) / hAA_norm[aLine[1]]["sde"].to_f)
            #hObj[aLine[0]][aLine[1]]["col"] = (aLine[2].to_f-hAA_norm[aLine[1]]["val"]).to_f / hAA_norm[aLine[1]]["sde"].to_f
            
            elsif (aLine[0] !~ /^SP/)
              hObj[aLine[0]][aLine[1]]["val"] = sprintf "%.2f",aLine[2]
              hObj[aLine[0]][aLine[1]]["col"] = get_aa_color( (aLine[2].to_f-hF_norm[aLine[1]]["val"]).to_f / hF_norm[aLine[1]]["sde"].to_f) if ((aLine[0]=~/SF/) && ((aLine[1]=~/^hydrophobicity/) || (aLine[1]=~/^percent positive residues/) || (aLine[1]=~/^aliphatic index/) || (aLine[1]=~/^isoelectric point/) || (aLine[1]=~/^molecular weight/) || (aLine[1]=~/^charge/) || (aLine[1]=~/^percent negative residues/) || (aLine[1]=~/^molar extinction coefficient/)))
           
            end
          end
      end
     
      hObj["TM_TOPOL"].chop() if hObj["TM_TOPOL"] =~ /\;$/
      hObj = get_seq_class(hObj);
    end
      return(hObj)
   end

   def get_cats (hObj)
     begin
        # connect to the MySQL server
        dbh = DBI.connect("dbi:Mysql:featureAnno:bioinf5","root","bT33xxT8")
        # get server version string and display it
        sth = dbh.execute("select GO_IDX, NAME, TYPE, MCC, PPV from go where USED =1")
        while row = sth.fetch do
          #$go,$name,$type,$ppv,$mcc
          type = row[2] =~ /P/ ? "process" : "function"
         if hObj["PRED"].has_key?(row[0].to_s)
           
            hObj["PRED"][row[0].to_s]["type"] = type
          end

        if(row[2] =~ /P/)
          i = hObj.has_key?("BP") ? hObj["BP"].length : 0
          hObj["BP"][i]["id"] = format_go(row[0].to_s)
          hObj["BP"][i]["name"] = row[1]
          hObj["BP"][i]["ppv"] = printf "%.3f", row[3]
          hObj["BP"][i]["mcc"] = printf "%.3f", row[4]
        else
          i = hObj.has_key?("MF") ? hObj["BP"].length : 0
          hObj["MF"][i]["id"] = format_go(row[0].to_s)
          hObj["MF"][i]["name"] = row[1]
          hObj["MF"][i]["ppv"] = printf "%.3f", row[3]
          hObj["MF"][i]["mcc"] = printf "%.3f", row[4]
        end
        end
        sth.finish

     rescue DBI::DatabaseError => e
        puts "An error occurred"
        puts "Error code: #{e.err}"
        puts "Error message: #{e.errstr}"
        hObj["DB_ERROR"] = "Error code: #{e.err} : #{e.errstr}"
     ensure
        # disconnect from server
        dbh.disconnect if dbh

     end
     return(hObj)
   end

   def get_aa_order (hObj)
    aa = "ARNDCQEGHILKMFPSTWYV";
    hObj["AA_NAMES"]=aa;
    return(hObj)
   end

   def format_go (go)
     while go.length < 7
      go = "0"+go
     end
      go = "GO"+go
     return(go)
   end

   def format_seq(seq)
    i=0;
    aSeq = Array.new();

    while( i < seq.length()-49 )
      aSeq.push(seq[i,50]);
      i+=50;
    end
    aSeq.push(seq[i,seq.length()-1]);
    return aSeq;
   end

   def get_aa_color(val)

    ##--- color ramp ----##
    if(val.abs() >= 2.96 )
        return "signif1p" if val > 0
        return "signif1n"
    elsif(val.abs() >= 2.24)
        return "signif2p" if val > 0
        return "signif2n"
    elsif(val.abs() >= 1.96 )
        return "signif5p" if val > 0
        return "signif5n"
    elsif(val.abs() >= 1.645 )
        return "signif10p" if val > 0
        return "signif10n"
    end

    return "plain"
   end

   def get_seq_class(hObj)
      ##-- loop through sequence and assign classes --##
    str = Array.new()
    aseq = hObj["aa_seq"].split(//)

     aseq.each do |aa|
       str.push("-")
     end

    diso= hObj.has_key?("DI") ? format_dd(hObj["DI"],hObj["len"].to_i,'D') : str;
    ss  = hObj.has_key?("SS") ? format_ss(hObj["SS"],hObj["len"].to_i)     : str;
    phos= hObj.has_key?("PH") ? format_dd(hObj["PH"],hObj["len"].to_i,'P') : str;
    glyc= hObj.has_key?("GG") ? format_dd(hObj["GG"],hObj["len"].to_i,'G') : str;

    aseq.each_with_index do |aa, i|
         code = ss[i].to_s + diso[i].to_s + phos[i].to_s + glyc[i].to_s
         #code = "C" + "-" + phos[i].to_s + glyc[i].to_s
         #code = "C" + diso[i].to_s + phos[i].to_s + glyc[i].to_s
         hObj["seq_class"][i]=code;
    end

     return hObj
   end

    def format_dd(ddfeat,len,code)
      dd=Array.new()
      i = 0

      while( i <= len)
        ddfeat.keys.each do |idx|
          if i >= ddfeat[idx]["from"].to_i-1 && i < ddfeat[idx]["to"].to_i
            dd[i]=code
            break
          else
            dd[i]="-"
          end
        end
        i+=1
      end
      return dd
    end

    def format_ss(ssfeat, len)
      ss=Array.new()
      i = 0

      while ( i <= len)
        flag=1

         ssfeat.keys.each do |idx|
         	  if i >= ssfeat[idx]["from"].to_i && i < ssfeat[idx]["to"].to_i
           	  ss.push(ssfeat[idx]["type"].gsub("psipred",""));
             	flag=0;
            end
         end

        if flag == 1
          ss.push("C")
        end

        i+=1
        
      end

    return ss;
   end

end
