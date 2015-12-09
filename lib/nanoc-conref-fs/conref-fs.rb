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

  # This function calls the parent super, then adds additional metadata to the item.
  def parse(content_filename, meta_filename, _kind)
    meta, content = super
    apply_attributes(meta, content_filename)
    [meta, content]
  end

  def apply_attributes(meta, content_filename)
    page_vars = NanocConrefFS::Conrefifier.file_variables(@site_config[:page_variables], content_filename)

    unless page_vars[:data_association].nil?
      association = page_vars[:data_association]
      toc = NanocConrefFS::Variables.fetch_data_file(association)
      meta[:parents] = create_parents(toc, meta)
      meta[:children] = create_children(toc, meta)
    end

    meta[:unparsed_content] = @unparsed_content

    page_vars.each_pair do |name, value|
      meta[name.to_s] = value
    end
  end

  # This file reads each piece of content as it comes in. It also applies the conref variables
  # (demarcated by Liquid's {{ }} tags) using both the data/ folder and any variables defined
  # within the nanoc.yaml config file
  def read(filename)
    content = super
    return content unless filename.start_with?('content', 'layouts')
    @unparsed_content = content
    NanocConrefFS::Conrefifier.liquify(filename, content, @site_config)
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
