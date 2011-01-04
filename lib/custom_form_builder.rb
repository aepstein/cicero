class CustomFormBuilder < Formtastic::SemanticFormBuilder

  def datepicker_input(method, options = {})
    format = options[:format] || ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:default] || '%d %b %Y'
    string_input(method, datepicker_options(format, object.send(method)).merge(options))
  end

  def datepicker_options(format, value = nil)
    datepicker_options = {:value => value.try(:strftime, format), :input_html => {:class => 'ui-datepicker'}}
  end

  def datetimepicker_input(method, options = {})
    format = options[:format] || ActiveSupport::CoreExtensions::Date::Conversions::DATETIME_FORMATS[:default] || '%d %b %Y'
    string_input(method, datepicker_options(format, object.send(method)).merge(options))
  end

  def datetimepicker_options(format, value = nil)
    datepicker_options = {:value => value.try(:strftime, format), :input_html => {:class => 'ui-datetimepicker'}}
  end

  # A method that deals with auto_complete field
  def string_with_auto_complete_input(method, options = {})
    html_options = options.delete(:input_html) || {}
    remote_options = options.delete(:remote) || {}

    self.label( method, options_for_label(options)) +
    self.send(:text_field_with_auto_complete, method, default_string_options(method, :string).merge(html_options), remote_options)
  end

  # A method that provides read-only access to an attribute
  def read_only_input(method, options = {})
    html_options = options.delete(:input_html)
    html_options[:escape_method] ||= 'h'

    self.label( method, options_for_label(options) ) +
    self.send( html_options[:escape_method], self.object.send(method) )
  end

  def text_field_with_auto_complete(method, local_options, remote_options)
    @template.text_field_with_auto_complete( @object_name, method, objectify_options(local_options), remote_options )
  end

end

