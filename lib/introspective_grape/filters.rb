module IntrospectiveGrape::Filters
  #
  # Allow filters on all whitelisted model attributes (from api_params) and declare
  # customer filters for the index in a method.
  #

  def custom_filter(*args)
    custom_filters( *args )
  end

  def custom_filters(*args)
    @custom_filters ||= {}
    @custom_filters   = Hash[*args].merge(@custom_filters) if args.present?
    @custom_filters
  end

  def simple_filters(klass, model, api_params)
    @simple_filters ||= api_params.select {|p| p.is_a? Symbol }.map { |field|
      (klass.param_type(model,field) == DateTime ? ["#{field}_start", "#{field}_end"] : field.to_s)
    }.flatten
  end

  def timestamp_filter(klass,model,field)
    filter = field.sub(/_(end|start)\z/,'')
    if field =~ /_(end|start)\z/ && klass.param_type(model,filter) == DateTime
      filter
    else
      false
    end
  end

  def identifier_filter(klass,model,field)
    if field.ends_with?('id') && klass.param_type(model,field) == Integer
      field
    else
      false
    end
  end

  def declare_filter_params(dsl, klass, model, api_params)
    # Declare optional parameters for filtering parameters, create two parameters per
    # timestamp, a Start and an End, to apply a date range.
    simple_filters(klass, model, api_params).each do |field|
      if timestamp_filter(klass,model,field)
        terminal = field.ends_with?("_start") ? "initial" : "terminal" 
        dsl.optional field, type: klass.param_type(model,field), description: "Constrain #{field} by #{terminal} date."
      elsif identifier_filter(klass,model,field)
        dsl.optional field, type: Array[Integer], coerce_with: ->(val) { val.split(',') }, description: "Filter by a comma separated list of integers."
      else
        dsl.optional field, type: klass.param_type(model,field), description: "Filter on #{field} by value."
      end
    end

    custom_filters.each do |filter,details|
      dsl.optional filter, details
    end

    dsl.optional :filter, type: String, description: "JSON of conditions for query. If you're familiar with ActiveRecord's query conventions you can build more complex filters, e.g. against included child associations, e.g. {\"<association_name>_<parent>\":{\"field\":\"value\"}}"

  end

  def apply_filter_params(klass, model, api_params, params, records)
    simple_filters(klass, model, api_params).each do |field|
      next if params[field].blank?

      if timestamp_filter(klass,model,field)
        op      = field.ends_with?("_start") ? ">=" : "<="
        records = records.where("#{timestamp_filter(klass,model,field)} #{op} ?", Time.zone.parse(params[field]))
      elsif model.respond_to?("#{field}=")
        records = records.send("#{field}=", params[field])
      else
        records = records.where(field => params[field])
      end
    end

    klass.custom_filters.each do |filter,details|
      records = records.send(filter, params[filter])
    end


    if params[:filter].present?
      filters = JSON.parse( params[:filter].delete('\\') )
      filters.each do |key, value|
        records = records.where(key => value) if value.present?
      end
    end

    records
  end
end
