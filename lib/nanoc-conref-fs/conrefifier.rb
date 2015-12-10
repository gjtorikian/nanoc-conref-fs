require 'liquid'

module NanocConrefFS
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

    def self.liquify(filename, content, config)
      page_vars = NanocConrefFS::Conrefifier.file_variables(config[:page_variables], filename)
      page_vars = { :page => page_vars }.merge(NanocConrefFS::Variables.variables)

      # we must obfuscate essential ExtendedMarkdownFilter content
      content = content.gsub(/\{\{\s*#(\S+)\s*\}\}/, '[[#\1]]')
      content = content.gsub(/\{\{\s*\/(\S+)\s*\}\}/, '[[/\1]]')
      content = content.gsub(/\{\{\s*(octicon-\S+\s*[^\}]+)\s*\}\}/, '[[\1]]')

      begin
        result = content

        # This pass replaces any matched conditionals
        if result =~ NanocConrefFS::Conrefifier::BLOCK_SUB || result =~ Conrefifier::SINGLE_SUB
          result = NanocConrefFS::Conrefifier.apply_liquid(result, page_vars)
        end

        # This second pass renders any previously inserted
        # data conditionals within the body. If a Liquid parse
        # returns a blank string, we'll return the original
        if result =~ NanocConrefFS::Conrefifier::SINGLE_SUB
          result = result.gsub(NanocConrefFS::Conrefifier::SINGLE_SUB) do |match|
            liquified = NanocConrefFS::Conrefifier.apply_liquid(match, page_vars)
            liquified.empty? ? match : liquified
          end
        end
      rescue Liquid::SyntaxError => e
        # unrecognized Liquid, so just return the content
        STDERR.puts "Could not convert #{filename}: #{e.message}"
      rescue => e
        raise "#{e.message}: #{e.inspect}"
      end
    end

    def self.apply_liquid(content, data_vars)
      data_vars['page'] = data_vars[:page].stringify_keys
      Liquid::Template.parse(content, :error_mode => :warn).render(data_vars)
    end
  end
end
