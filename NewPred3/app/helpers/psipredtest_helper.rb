module PsipredtestHelper

  #Takes a PSIPRED horiz file output and parses the prediction line for the residue assignments
  def parsePsipredTest(predictionText)
    hAnnotations = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }

    #Ok handle the first line, and split each prediction chunk in to sections
    predictionText = predictionText.data.gsub(/# PSIPRED HFORMAT \(PSIPRED V3.0\)\n\n/, "")
    alignment_segments = predictionText.split(/\n{3}/)
    if alignment_segments.length == 0
      alignment_segments = temp_data
    end

    #now split each chunk in to lines
    pred_count = 0
    conf_count = 0
    alignment_segments.each_with_index do |segment, index|
      lines_temp = segment.split(/\n/)
      lines = []
      #gets rid of the 0 length lines
      lines_temp.each do |line|
        if line.length > 0
          lines.push(line)
        end
      end

      lines.each_with_index do |line, index2|
        line.chomp
        line.gsub!(/Conf:\s+/,"")
        line.gsub!(/Pred:\s+/,"")

        characters = line.split("")
        characters.each do |character|

          if(index2 == 0)
            hAnnotations[conf_count]["CONF"]=character
            conf_count+=1
          elsif(index2 == 1)
            hAnnotations[pred_count]["PRED"]=character
            pred_count+=1
          end
        end

      end

    end

    return hAnnotations
  end

  def parseMemsatSVMTest(predictionText,length)
    hAnnotations = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    data_segments = predictionText.data.split(/Results:\n/)
    outBegin = 0
    hHelices = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    hPoreLining = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }

    data_segments.each_with_index do |segment, index|
      if index == 1
        lines = segment.split(/\n/)

        lines.each do |line|
          data = line.split(/:\s+/)
          if data[0] =~ /N-terminal/
            if data[1] =~ /out/
              outBegin = 1
            end
          end
          if data[0] =~ /Topology/
            helices = data[1].split(/,/)
            helices.each_with_index do |helix, index2|
              if(helix =~ /(\d+)-(\d+)/)
                hHelices[index2]["START"] = $1
                hHelices[index2]["STOP"] = $2
              end
            end
          end
          if data[0] =~ /Pore-lining helices/
            helices = data[1].split(/,/)
            helices.each_with_index do |helix, index2|
              if(helix =~ /(\d+)-(\d+)/)
                hPoreLining[index2]["START"] = $1
                hPoreLining[index2]["STOP"] = $2
              end
            end
          end

        end
      end
    end

    for i in 0..length
      coil = "C"
      if outBegin == 0
        coil = "C"
      else
        coil = "E"
      end

      helixFound = 0
      hHelices.keys.each do |key|
        if i >= hHelices[key]["START"].to_i && i <= hHelices[key]["STOP"].to_i
          hAnnotations[i]["PRED"] = "T"
          helixFound = 1
          break
        end
      end

      hPoreLining.keys.each do |key|
      if i >= hPoreLining[key]["START"].to_i && i <= hPoreLining[key]["STOP"].to_i
          hAnnotations[i]["PRED"] = "P"
          helixFound = 1
          break
        end
      end

      if helixFound == 0
        hAnnotations[i]["PRED"] = coil
      end

      if i > 0
        if (hAnnotations[i]["PRED"] =~ /T/ || hAnnotations[i]["PRED"] =~ /P/) && hAnnotations[i]["PRED"] !~ /#{hAnnotations[i-1]["PRED"]}/
          if outBegin == 0
            outBegin =1
          else
            outBegin = 0
          end
        end
      end

    end
    return hAnnotations
  end

  def parseDisopredTest(predictionText)
    hAnnotations = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    results = predictionText.data.split(/\n/)

    res_count = 0
    results.each do |line|
      if(line =~ /pred:\s(.+)/)
        prediction_portion = $1
        tokens = prediction_portion.split(//)
        tokens.each do |token|
          if token =~ /\*/
            hAnnotations[res_count]["PRED"]="D"
          else
            hAnnotations[res_count]["PRED"]="R"
          end
          res_count+=1
        end

      end
    end

    return hAnnotations
  end

  def parseDompsiTest(predictionText, length)
    hAnnotations = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    positions = []
    lines = predictionText.data.split(/\n/)
    lines.each do |line|
          if line =~ /Domain Bounary locations predicted DPS: (.+)/
            boundaries = $1
            if boundaries.length > 0
              positions = boundaries.split(/,/)
            end
          end
        end

    for i in 0..length
      hAnnotations[i]["PRED"]="C"
      
      positions.each do |pos|
        if (pos.to_i-1) == i
          hAnnotations[i]["PRED"]="B"
        end
      end
      
    end

    return hAnnotations

  end

  def parseDomsseaTest(predictionText, length)
    hAnnotations = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    boundarySet = []

    lines = predictionText.data.split(/\n/)
      lines.each_with_index do |line, index| 
        entries = line.split(/\t/)
        if index != 0
          positions = entries[4].split(/,/)
          positions.each do |pos|
             boundarySet.push(pos)
          end
        end
      end
      
    for i in 0..length
      hAnnotations[i]["PRED"]="C"

      boundarySet.each do |pos|
        if (pos.to_i-1) == i
          hAnnotations[i]["PRED"]="B"
        end
      end

    end

    return hAnnotations
  end
  
end