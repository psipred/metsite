module TestHarness::ReportManagerHelper
  def placeholder(message = 'Nothing to display', options = {}, &proc)
    # set default options
    o = { :class => 'placeholder', :tag => 'p' }.merge(options)

    # wrap the results of the supplied block, or
    # just print out the message
    if proc
      t = o.delete(:tag)
      concat tag(t, o, true), proc.binding
      yield
      concat "</#{t}>", proc.binding
    else
      content_tag o.delete(:tag), message, o
    end
  end
  
  def placeholder_unless(condition, *args, &proc)
    condition ? proc.call : concat(placeholder(args), proc.binding)
  end

  def table(collection, headers, options = {}, &proc)
    options.reverse_merge!({
        :placeholder  => 'Nothing to display',
        :caption      => nil,
        :summary      => nil,
        :footer       => ''
      })
    placeholder_unless collection.any?, options[:placeholder] do
      summary = options[:summary] || "A list of #{collection.first.class.to_s.pluralize}"
      output = "<table summary=\"#{summary}\">\n"
      output << content_tag('caption', options[:caption]) if options[:caption]
      output << "\t<caption>#{options[:caption]}</caption>\n" if options[:caption]
      output << content_tag('thead', content_tag('tr', headers.collect { |h| "\n\t" + content_tag('th', h) }))
      output << "<tfoot><tr>" + content_tag('th', options[:footer], :colspan => headers.size) + "</tr></tfoot>\n" if options[:footer]
      output << "<tbody>\n"
      concat(output, proc.binding)
      collection.each do |row|
        proc.call(row, cycle("#ccc",""))
      end
      concat("</tbody>\n</table>\n", proc.binding)
    end
  end

end
