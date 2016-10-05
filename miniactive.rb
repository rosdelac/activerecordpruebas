module MiniActiveRecord
  class InvalidAttributeError < StandardError; end
  class NotConnectedError < StandardError; end

  class Model

    def self.inherited(klass)
    end

    def self.database=(filename)
      @filename = filename
      @connection = SQLite3::Database.new(@filename)

      # Return the results as a Hash of field/value pairs
      # instead of an Array of values
      @connection.results_as_hash  = true

      # Automatically translate data from database into
      # reasonably appropriate Ruby objects
      @connection.type_translation = true
    end

    def self.filename
      @filename
    end

    def self.connection
      @connection
    end

    def self.execute(query, *args)
      raise NotConnectedError, "You are not connected to a database." unless connected?

      prepared_args = args.map { |arg| prepare_value(arg) }
      MiniActiveRecord::Model.connection.execute(query, *prepared_args)
    end

    def self.connected?
      !self.connection.nil?
    end

    def self.attribute_names
      @attribute_names
    end

    def self.attribute_names=(attribute_names)
      @attribute_names = attribute_names
    end

    def self.last_insert_row_id
      MiniActiveRecord::Model.connection.last_insert_row_id
    end

    def valid_attribute?(attribute)
      self.class.attribute_names.include? attribute
    end

    def raise_error_if_invalid_attribute!(attributes)
      # This guarantees that attributes is an array, so we can call both:
      #   raise_error_if_invalid_attribute!("id")
      # and
      #   raise_error_if_invalid_attribute!(["id", "name"])
      Array(attributes).each do |attribute|
        unless valid_attribute?(attribute)
          raise InvalidAttributeError, "Invalid attribute for #{self.class}: #{attribute}"
        end
      end
    end

    def to_s
      attribute_str = self.attributes.map { |key, val| "#{key}: #{val.inspect}" }.join(', ')
      "#<#{self.class} #{attribute_str}>"
    end


    private

    def self.prepare_value(value)
      case value
      when Time, DateTime, Date
        value.to_s
      else
        value
      end
    end

  end

end
