require 'liquid'

module Conrefifier
  def self.file_variables(variables, path)
    return {} if variables.nil?

    data_vars = {}
    scopes = variables.select { |v| v[:scope][:path].empty? || Regexp.new(v[:scope][:path]) =~ path }
    scopes.each do |scope|
      data_vars = data_vars.merge(scope[:values])
    end
    data_vars
  end

  def self.apply_liquid(content, data_vars)
    ::Liquid::Template.parse(content).render(data_vars.deep_stringify_keys)
  end
end
