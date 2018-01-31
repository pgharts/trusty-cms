class SnippetFinder
  class << self
    def find(id)
      find_map('find',id)
    end

    def find_by_name(name)
      find_map('find_by_name', name)
    end

    def finder_types
      [Snippet]
    end

    private

    def find_map(meth, *args)
      finder_types.find{|type|
        found = type.send(meth, *args)
        return found if found
      }
    end
  end
end