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
    frontmatter_vars = { :page => page_vars }.merge(NanocConrefFS::Variables.variables[rep])

    puts "for ", item[:filename]
    puts "it is ", page_vars
    unless page_vars[:data_association].nil?
      association = page_vars[:data_association]
      toc = NanocConrefFS::Variables.fetch_data_file(association, rep)
      item[:parents] = NanocConrefFS::Ancestry::create_parents(toc, item.attributes)
      item[:children] = NanocConrefFS::Ancestry::create_children(toc, item.attributes)
    end

    page_vars.each_pair do |key, value|
      item[key] = value
    end

    item.attributes.each_pair do |key, value|
      if value.is_a?(Array)
        frontmatter = []
        # tried to do this with `map` and it completely erased the attributes
        # array; not sure why
        value.each do |v|
          frontmatter << if v =~ NanocConrefFS::Conrefifier::SINGLE_SUB
                           NanocConrefFS::Conrefifier.apply_liquid(v, frontmatter_vars)
                         else
                           v
                         end
        end
        item[key] = frontmatter
      else
        if value =~ NanocConrefFS::Conrefifier::SINGLE_SUB
          value = NanocConrefFS::Conrefifier.apply_liquid(value, frontmatter_vars)
          item[key] = value
        end
      end
    end
  end

  # There are a lot of problems when trying to parse liquid
  # out of the frontmatter—all of them dealing with collision between
  # the { character in Liquid and its signfigance in YAML. We'll overload
  # the parse method here to resolve those issues ahead of time.
  def parse(content_filename, meta_filename, _kind)
    # Read data
    data = read(content_filename)

    # Check presence of metadata section
    return [{}, data] if data !~ /\A-{3,5}\s*$/

    # Split data
    pieces = data.split(/^(-{5}|-{3})[ \t]*\r?\n?/, 3)
    if pieces.size < 4
      raise RuntimeError.new(
        "The file '#{content_filename}' appears to start with a metadata section (three or five dashes at the top) but it does not seem to be in the correct format.",
      )
    end

    # N.B. the only change to the original function
    pieces[2].gsub!(/^([^:]+): (\{\{.+)/, '\1: \'\2\'')

    # Parse
    begin
      meta = YAML.load(pieces[2]) || {}
    rescue Exception => e
      raise "Could not parse YAML for #{content_filename}: #{e.message}"
    end
    verify_meta(meta, content_filename)
    content = pieces[4]

    # Done
    [meta, content]
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
      "#{article.parameterize}.md"
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
