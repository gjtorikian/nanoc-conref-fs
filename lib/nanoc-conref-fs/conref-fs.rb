require_relative 'conrefifier'

class ConrefFS < Nanoc::DataSource
  include Nanoc::DataSources::Filesystem

  identifier :conref_fs

  # Before iterating over the file objects, this method loads the data folder
  # and applies to to an ivar for later usage.
  def load_objects(dir_name, kind, klass)
    if klass == Nanoc::Int::Item && @vars.nil?
      data = Datafiles.process(@site_config)
      @vars = { 'site' => { 'config' => @site_config.to_h, 'data' => data } }
    end
    super
  end

  # This function calls the parent super, then adds additional metadata to the item.
  def parse(content_filename, meta_filename, _kind)
    meta, content = super
    page_vars = Conrefifier.file_variables(@site_config[:page_variables], content_filename)
    unless page_vars[:data_association].nil?
      association = page_vars[:data_association]
      reference = association.split('.')
      toc = @vars['site']['data']
      while key = reference.shift
        toc = toc[key]
      end
      meta['parents'] = find_parents(toc, meta['title'])
    end
    [meta, content]
  end

  # Given a category file, this method finds its parent.
  def find_parents(toc, title)
    parents = ''
    toc.keys.each do |key|
      toc[key].each do |item|
        if item.is_a?(Hash)
          if item.keys.include?(title)
            parents = key
            break
          else
            if item[item.keys.first].include?(title)
              parents = key
              break
            end
          end
        elsif title == item
          parents = key
          break
        end
      end
      break unless parents.empty?
    end
    parents
  end

  # This file reads each piece of content as it comes in. It also applies the conref variables
  # (demarcated by Liquid's {{ }} tags) using both the data/ folder and any variables defined
  # within the nanoc.yaml config file
  def read(filename)
    begin
      page_vars = Conrefifier.file_variables(@site_config[:page_variables], filename)
      page_vars = { :page => page_vars }.merge(@vars)

      data = File.read(filename)
      return data unless filename.start_with?('content')

      # we must obfuscate essential ExtendedMarkdownFilter content
      data = data.gsub(/\{\{\s*#(\S+)\s*\}\}/, '[[#\1]]')
      data = data.gsub(/\{\{\s*\/(\S+)\s*\}\}/, '[[/\1]]')
      data = data.gsub(/\{\{\s*(octicon-\S+\s*[^\}]+)\s*\}\}/, '[[\1]]')

      # This first pass converts the frontmatter variables,
      # and inserts data variables into the body
      result = Conrefifier.apply_liquid(data, page_vars)
      # This second application renders the previously inserted
      # data conditionals within the body
      result = Conrefifier.apply_liquid(result, page_vars)
    rescue => e
      raise RuntimeError.new("Could not read #{filename}: #{e.inspect}")
    end
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
