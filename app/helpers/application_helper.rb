module ApplicationHelper

  def nested_errors(object)
    return nil if object.errors.empty?
    e = object.errors.inject([]) do |errors, (attribute, message)|
      if attribute =~ /\./
        nested_attribute = object.send( attribute.to_s.match( /^([^\.]+)\./ )[1] )
        if nested_attribute.respond_to?(:each)
          nested_attribute.each do |nested_object|
            errors << nested_errors( nested_object )
          end
        else
          errors << nested_errors( nested_object )
        end
      else
        if attribute == :base
          errors << message
        else
          errors << "#{attribute} #{message}"
        end
      end
      errors
    end
    "#{object} has the following errors:\n".html_safe + (
    content_tag( :ul ) do
      e.map { |error| error.present? ? content_tag( :li, error ) : '' }.
        join("\n").html_safe
    end )
  end

  def markdown( content )
    sanitize Markdown.new(content).to_html
  end

  def table_row_tag(increment=true, &block)
    content_tag 'tr', capture(&block), :class => table_row_class(increment)
  end

  def table_row_class(increment=true)
    @table_row_class ||= 'row1'
    out = @table_row_class
    @table_row_class = ( @table_row_class == 'row1' ? 'row2' : 'row1' ) if increment
    @table_row_class = 'row1' if increment == :reset
    out
  end

end

