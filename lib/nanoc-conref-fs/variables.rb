module NanocConrefFS
  # Unsure why attr_accessor does not work here
  module Variables
    def self.variables
      @variables
    end

    def self.variables=(variables)
      @variables = variables
    end

    def self.data_files
      @data_files
    end

    def self.data_files=(data_files)
      @data_files = data_files
    end

    def self.fetch_data_file(association, rep = :default)
      return nil unless association
      reference = association.split('.')
      data = @variables[rep]['site']['data']
      while key = reference.shift
        data = data[key]
      end
      data
    end
  end
end
