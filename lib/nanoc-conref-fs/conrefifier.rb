require 'liquid'

module NanocConrefFS
  module Conrefifier
    SINGLE_SUB = /(\{\{[^\}]+\}\})/m
    BLOCK_SUB = /\{% (?:if|unless).+? %\}.*?\{% end(?:if|unless) %\}/m

    def self.file_variables(variables, path, rep)
      return {} if variables.nil?

      data_vars = {}

      scopes = variables.select do |v|
        scope_block = v[:scope]
        scoped_path = scope_block[:path].empty? || Regexp.new(scope_block[:path]) =~ path
        scoped_rep  = scope_block[:reps].nil? || scope_block[:reps].include?(rep)
        scoped_path && scoped_rep
      end

      # I benchmarked that assignment is much
      # faster than merging an empty hash
      if scopes.length == 1
        data_vars = scopes.first[:values]
      else
        scopes.each do |scope|
          data_vars = data_vars.merge(scope[:values])
        end
      end

      data_vars
    end

    def self.liquify(config, path:, content:, rep:)
      page_vars = NanocConrefFS::Conrefifier.file_variables(config[:page_variables], path, rep)
      page_vars = { page: page_vars }.merge(NanocConrefFS::Variables.variables[rep])

      # we must obfuscate essential ExtendedMarkdownFilter content
      content = content.gsub(/\{\{\s*#(\S+)\s*\}\}/, '[[#\1]]')
      content = content.gsub(/\{\{\s*\/(\S+)\s*\}\}/, '[[/\1]]')
      content = content.gsub(/\{\{\s*(octicon-\S+\s*[^\}]+)\s*\}\}/, '[[\1]]')

      begin
        result = content

        # This pass replaces any matched conditionals
        if result =~ NanocConrefFS::Conrefifier::BLOCK_SUB || result =~ NanocConrefFS::Conrefifier::SINGLE_SUB
          result = NanocConrefFS::Conrefifier.apply_liquid(result, page_vars)
        end
      rescue Liquid::SyntaxError => e
        # unrecognized Liquid, so just return the content
        STDERR.puts "Could not convert #{result}: #{e.message}"
      rescue => e
        raise "#{e.message}: #{e.inspect}"
      end

      result = result.gsub(/\[\[\s*#(\S+)\s*\]\]/, '{{#\1}}')
      result = result.gsub(/\[\[\s*\/(\S+)\s*\]\]/, '{{/\1}}')
      result = result.gsub(/\[\[\s*(octicon-\S+\s*[^\]]+)\s*\]\]/, '{{\1}}')

      result
    end

    def self.apply_liquid(content, data_vars)
      data_vars['page'] = data_vars[:page].stringify_keys
      result = Liquid::Template.parse(content, error_mode: :warn).render(data_vars)
      # This second pass renders any previously inserted
      # data conditionals within the body. If a Liquid parse
      # returns a blank string, we'll return the original
      if result =~ NanocConrefFS::Conrefifier::SINGLE_SUB
        result = result.gsub(NanocConrefFS::Conrefifier::SINGLE_SUB) do |match|
          liquified = NanocConrefFS::Conrefifier.apply_liquid(match, data_vars)
          liquified.empty? ? match : liquified
        end
      end
      result
    end
  end
end
