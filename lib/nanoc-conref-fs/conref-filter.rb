module Nanoc
  class ItemView
    # allows apply_attributes to create new item attributes
    def []=(key, value)
      unwrap.attributes[key] = value
    end
  end
end

module Nanoc::HashExtensions
  alias_method :original_freeze, :__nanoc_freeze_recursively

  # prevents the item's frozen attributes from remaining frozen
  def __nanoc_freeze_recursively
    return if caller.first =~ %r{base/entities/document.rb}
    original_freeze
  end
end

class ConrefFSFilter < Nanoc::Filter
  identifier :'conref-fs-filter'

  def run(content, _)
    ConrefFS.apply_attributes(@config, item)
    NanocConrefFS::Conrefifier.liquify(@item[:filename], content, @config.unwrap)
  end
end
