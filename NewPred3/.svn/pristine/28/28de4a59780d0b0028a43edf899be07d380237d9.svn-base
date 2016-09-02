# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def pretty_error_messages_for(object_name, options = {})
         options = options.symbolize_keys
           object = instance_variable_get("@#{object_name}")
           if object && !object.errors.empty?

              content_tag :div, :class => options[:class] || "errorExplanation", :id => options[:id] || "errorExplanation"  do

                concat(content_tag( options[:header_tag] || "h2",  "#{pluralize(object.errors.count, "problem")} prevented this #{object_name.to_s.gsub("_", " ")} from being submitted:")) +
                concat(listing(object.errors.values))           
                
              #concat(content_tag("ul", object.errors.values.each { |msg| concat(content_tag("li", msg[0] )) }))
              
              end
             
           else
             
       end
   end

   def listing(items)
    content_tag :ul do
      items.each {|item| concat(content_tag(:li, item[0]))}
    end
   end
end