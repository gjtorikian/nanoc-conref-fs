require_relative 'conrefifier'
require 'active_support/core_ext/string'

class ConrefFS < Nanoc::DataSource
  include Nanoc::DataSources::Filesystem
  include NanocConrefFS::Variables
  include NanocConrefFS::Ancestry

  identifier :'conref-fs'

  # Before iterating over the file objects, this method loads the data folder
  # and applies it to an ivar for later usage.
  def up
    data_files = NanocConrefFS::Datafiles.collect_data(data_dir_name)
    NanocConrefFS::Variables.data_files = data_files
    NanocConrefFS::Variables.variables = {}
    reps = @config[:reps] || [:default]
    reps.each { |rep| ConrefFS.load_data_folder(@site_config, rep) }
  end

  def data_dir_name
    config.fetch(:data_dir) { |_| 'data' }
  end

  def self.load_data_folder(config, rep)
    return unless NanocConrefFS::Variables.variables[rep].nil?
    data_files = NanocConrefFS::Variables.data_files
    data = NanocConrefFS::Datafiles.process(data_files, config, rep)
    NanocConrefFS::Variables.variables[rep] = { 'site' => { 'config' => config, 'data' => data } }
  end

  def self.apply_attributes(config, item, rep)
    page_vars = NanocConrefFS::Conrefifier.file_variables(config[:page_variables], item[:filename], rep)

    unless page_vars[:data_association].nil?
      association = page_vars[:data_association]
      toc = NanocConrefFS::Variables.fetch_data_file(association, rep)
      item[:parents] = NanocConrefFS::Ancestry::create_parents(toc, item.attributes)
      item[:children] = NanocConrefFS::Ancestry::create_children(toc, item.attributes)
    end

    page_vars.each_pair do |key, value|
      item[key] = value
    end

    page_vars = { :page => page_vars }.merge(NanocConrefFS::Variables.variables[rep])

    item.attributes.each_pair do |key, value|
      # This pass replaces any matched conditionals in the frontmatter
      if value =~ NanocConrefFS::Conrefifier::BLOCK_SUB || value =~ NanocConrefFS::Conrefifier::SINGLE_SUB
        value = NanocConrefFS::Conrefifier.apply_liquid(value, page_vars)
        item[key] = value
      end
    end
  end

  # This file reads each piece of content as it comes in. It also catches and fixes
  # an error where YAML frontmatter cannot start with a curly brace
  # (eg. intro: '{{ ... }}')
  def read(filename)
    content = super
    content.gsub(/^([^:]+): (\{\{.+)/, '\1: \'\2\'')
  end

  def self.create_ignore_rules(rep, file)
    current_articles = NanocConrefFS::Variables.fetch_data_file(file, rep)
    current_articles = flatten_list(current_articles).flatten
    current_articles = fix_nested_content(current_articles)

    basic_yaml = NanocConrefFS::Variables.data_files["data/#{file.tr!('.', '/')}.yml"]
    basic_yaml.gsub!(/\{%.+/, '')
    full_file = YAML.load(basic_yaml)

    full_user_articles = flatten_list(full_file).flatten
    full_user_articles = fix_nested_content(full_user_articles)

    blacklisted_articles = full_user_articles - current_articles
    blacklisted_articles.map do |article|
      "**/#{article.parameterize}.md"
    end
  end

  def self.flatten_list(arr)
    result = []
    return result unless arr
    arr.each do |item|
      if item.is_a?(Hash)
        item.each_pair do |key, value|
          result << key
          result.concat(value)
        end
      else
        result << item
      end
    end

    result
  end

  def self.fix_nested_content(articles)
    articles.delete_if do |i|
      if i.is_a? Hash
        articles.concat(i.keys.concat(i.values).flatten)
        true
      else
        false
      end
    end
    articles
  end

  # This method is extracted from the Nanoc default FS
  def filename_for(base_filename, ext)
    if ext.nil?
      nil
    elsif ext.empty?
      base_filename
    else
      base_filename + '.' + ext
    end
  end

  # This method is extracted from the Nanoc default FS
  def identifier_for_filename(filename)
    if config[:identifier_type] == 'full'
      return Nanoc::Identifier.new(filename)
    end

    if filename =~ /(^|\/)index(\.[^\/]+)?$/
      regex = @config && @config[:allow_periods_in_identifiers] ? /\/?(index)?(\.[^\/\.]+)?$/ : /\/?index(\.[^\/]+)?$/
    else
      regex = @config && @config[:allow_periods_in_identifiers] ? /\.[^\/\.]+$/ : /\.[^\/]+$/
    end
    Nanoc::Identifier.new(filename.sub(regex, ''), type: :legacy)
  end
end
