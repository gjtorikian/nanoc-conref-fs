require_relative 'conrefifier'

class ConrefFS < Nanoc::DataSource
  include Nanoc::DataSources::Filesystem
  include NanocConrefFS::Variables
  include NanocConrefFS::Ancestry

  identifier :'conref-fs'

  attr_reader :unparsed_content

  # Before iterating over the file objects, this method loads the data folder
  # and applies it to an ivar for later usage.
  def load_objects(dir_name, kind, klass)
    load_data_folder if klass == Nanoc::Int::Item && @variables.nil?
    super
  end

  def data_dir_name
    config.fetch(:data_dir, 'data')
  end

  def load_data_folder
    @data_files = NanocConrefFS::Datafiles.collect_data(data_dir_name)
    NanocConrefFS::Variables.data_files = @data_files
    data = NanocConrefFS::Datafiles.process(@data_files, @site_config)
    config = @site_config.to_h
    @variables = { 'site' => { 'config' => config, 'data' => data } }
    NanocConrefFS::Variables.variables = @variables
  end

  def self.apply_attributes(config, item)
    page_vars = NanocConrefFS::Conrefifier.file_variables(config[:page_variables], item[:filename])

    unless page_vars[:data_association].nil?
      association = page_vars[:data_association]
      toc = NanocConrefFS::Variables.fetch_data_file(association)
      item[:parents] = NanocConrefFS::Ancestry::create_parents(toc, item.attributes)
      item[:children] = NanocConrefFS::Ancestry::create_children(toc, item.attributes)
    end

    page_vars.each_pair do |key, value|
      item[key] = value
    end

    page_vars = { :page => page_vars }.merge(NanocConrefFS::Variables.variables)

    item.attributes.each_pair do |key, value|
      # This pass replaces any matched conditionals
      if value =~ NanocConrefFS::Conrefifier::BLOCK_SUB || value =~ NanocConrefFS::Conrefifier::SINGLE_SUB
        value = NanocConrefFS::Conrefifier.apply_liquid(value, page_vars)
        # This pass replaces any included conrefs
        if value =~ NanocConrefFS::Conrefifier::SINGLE_SUB
          value = NanocConrefFS::Conrefifier.apply_liquid(value, page_vars)
        end
        item[key] = value
      end
    end
  end

  # This file reads each piece of content as it comes in. It also applies the conref variables
  # (demarcated by Liquid's {{ }} tags) using both the data/ folder and any variables defined
  # within the nanoc.yaml config file
  def read(filename)
    content = super
    content = content.gsub(/\A---\s*\n(.*?\n?)^---\s*$\n?/m) do |frontmatter|
      frontmatter.gsub(/:\s*(\{\{.+)/) do |_|
        curly_match = Regexp.last_match[1]
        ": '#{curly_match}'"
      end
    end
    content
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
