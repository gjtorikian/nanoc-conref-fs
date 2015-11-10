require 'liquid'

module Conrefifier

  SINGLE_SUB = /(\{\{[^\}]+\}\})/m
  BLOCK_SUB = /\{% (?:if|unless).+? %\}.*?\{% end(?:if|unless) %\}/m

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
    data_vars['page'] = data_vars[:page].stringify_keys
    ::Liquid::Template.parse(content).render(data_vars)
  end
end
