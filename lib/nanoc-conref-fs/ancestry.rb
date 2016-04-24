module NanocConrefFS
  module Ancestry
    def create_parents(toc, meta)
      if toc.is_a?(Array)
        find_array_parents(toc, meta[:title])
      elsif toc.is_a?(Hash)
        find_hash_parents(toc, meta[:title])
      end
    end
    module_function :create_parents

    def create_children(toc, meta)
      if toc.is_a?(Array)
        find_array_children(toc, meta[:title])
      elsif toc.is_a?(Hash)
        find_hash_children(toc, meta[:title])
      end
    end
    module_function :create_children

    # Given a category file that's an array, this method finds
    # the parent of an item
    def find_array_parents(toc, title)
      parents = ''
      toc.each do |item|
        if item.is_a?(Hash)
          parents = find_hash_parents(item, title)
          break unless parents.empty?
        end
      end
      parents
    end
    module_function :find_array_parents

    # Given a category file that's a hash, this method finds
    # the parent of an item
    def find_hash_parents(toc, title)
      parents = ''
      toc.each_key do |key|
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
    module_function :find_hash_parents

    # Given a category file that's an array, this method finds
    # the children of an item, probably a map topic
    #
    # toc - the array containing the table of contents
    # title - the text title to return the children of
    #
    # Returns a flattened array of all descendants or nil.
    def find_array_children(toc, title)
      toc.each do |item|
        next unless item.is_a?(Hash)
        item.each_pair do |key, values|
          if key == title
            children = values.flatten
            return children unless children.empty?
          end
        end
      end
      # Found no children
      nil
    end
    module_function :find_array_children

    # Given a category file that's a hash, this method finds
    # the children of an item, probably a map topic
    #
    # toc - the hash containing the table of contents
    # title - the text title to return the children of
    #
    # Returns a flattened array of all descendants or nil.
    def find_hash_children(toc, title)
      toc.each_key do |key|
        toc[key].each do |item|
          next unless item.is_a?(Hash)
          if item[title]
            children = item.values.flatten
            return children unless children.empty?
          end
        end
      end
      # Found no children
      nil
    end
    module_function :find_hash_children
  end
end
