require_relative 'conrefifier'

class ConrefFS < Nanoc::DataSource
  include Nanoc::DataSources::Filesystem
  include NanocConrefFS::Variables
  include NanocConrefFS::Ancestry

  identifier :'conref-fs'

  # Before iterating over the file objects, this method loads the data folder
  # and applies it to an ivar for later usage.
  def load_objects(dir_name, kind, klass)
    if klass == Nanoc::Int::Item && NanocConrefFS::Variables.data_files.nil?
      data_files = NanocConrefFS::Datafiles.collect_data(data_dir_name)
      NanocConrefFS::Variables.data_files = data_files
      NanocConrefFS::Variables.variables = {}
    end
    super
  end

  def data_dir_name
    config.fetch(:data_dir, 'data')
  end

  def self.load_data_folder(config, rep)
    if NanocConrefFS::Variables.variables[rep].nil?
      data_files = NanocConrefFS::Variables.data_files
      data = NanocConrefFS::Datafiles.process(data_files, config, rep)
      NanocConrefFS::Variables.variables[rep] = { 'site' => { 'config' => config, 'data' => data } }
    end
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
      # This pass replaces any matched conditionals
      if value =~ NanocConrefFS::Conrefifier::BLOCK_SUB || value =~ NanocConrefFS::Conrefifier::SINGLE_SUB
        value = NanocConrefFS::Conrefifier.apply_liquid(value, page_vars)
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
