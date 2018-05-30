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

    def self.fetch_data_file(association, rep)
      return nil unless association
      reference = association.split('.')
      data = @variables[rep]['site'][ConrefFS.data_dir_name]
      while key = reference.shift
        begin
          data = data[key]
        rescue StandardError => ex
          raise "Unable to locate #{key} in #{@variables[rep]['site'].inspect}"
        end
      end
      data
    end
  end
end
