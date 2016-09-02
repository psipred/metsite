module BioSerfHelper
  def wrap_string(string, count, max)
    return String.new("Results too large to display") if string.length > max
    ret = String.new(string)
    i = 1
    while ((i * count) < ret.length)
      ret.insert(i*count, "\n")
      i = i + 1
    end
    return ret
  end
end
