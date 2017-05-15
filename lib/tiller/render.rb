module Tiller
  def self.render(template, options={})

    # This is only ever used when we parse top-level values for ERb syntax, we pass in each
    # datasource's global_values as a distinct namespace
    if options.has_key?(:namespace)
      b = binding
      ns =  options[:namespace]
      if RUBY_VERSION > "2.1.0"
        ns.each { |k, v| b.local_variable_set(k, v) }
      else
        ns.each { |k, v| b.eval("#{k} = '#{v}'") }
      end

      return ERB.new(template, nil, '-').result(ns.instance_eval { b })
    end

    ns = OpenStruct.new(Tiller::tiller)

    # This is used for rendering content in dynamic configuration files
    if options.has_key?(:direct_render)
      content = template
      return ERB.new(content, nil, '-').result(ns.instance_eval { binding })
    end

    if Tiller::templates.key?(template)
      content = Tiller::templates[template]
      ERB.new(content, nil, '-').result(ns.instance_eval { binding })
    else
      Tiller::log.warn("Warning : Requested render of non-existant template #{template}")
      ""
    end
  end

end