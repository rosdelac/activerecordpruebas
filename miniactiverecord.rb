module MiniActiveRecord
  class InvalidAttributeError < StandardError; end
  class NotConnectedError < StandardError; end

  class Model

    def initialize(attributes = {})
        attributes.symbolize_keys!
        raise_error_if_invalid_attribute!(attributes.keys)

        @attributes = {}

      self.class.attribute_names.each do |name|
      @attributes[name] = attributes[name]
        end

      @old_attributes = @attributes.dup
    end

    def save
      if new_record?
      results = insert!
    else
      results = update!
    end

      # When we save, remove changes between new and old attributes
      @old_attributes = @attributes.dup

      results
    end

    def self.all
      MiniActiveRecord::Model.execute("SELECT * FROM #{self}s").map do |row|
        self.new(row)
      end
    end

    def self.create(attributes)
      record = self.new(attributes)
      record.save

      record
    end

    def self.where(query, *args)
      MiniActiveRecord::Model.execute("SELECT * FROM #{self}s WHERE #{query}", *args).map do |row|
        self.new(row)
      end
    end

    def self.find(pk)
      self.where('id = ?', pk).first
    end

    def new_record?
      self[:id].nil?
    end

    def [](attribute)
      raise_error_if_invalid_attribute!(attribute)

      @attributes[attribute]
    end

    def []=(attribute, value)
      raise_error_if_invalid_attribute!(attribute)

      @attributes[attribute] = value
    end 

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

    def insert!
      self[:created_at] = DateTime.now
      self[:updated_at] = DateTime.now

      fields = self.attributes.keys
      values = self.attributes.values
      marks  = Array.new(fields.length) { '?' }.join(',')

      insert_sql = "INSERT INTO #{self.class}s (#{fields.join(',')}) VALUES (#{marks})"

      results = MiniActiveRecord::Model.execute(insert_sql, *values)

      # This fetches the new primary key and updates this instance
      self[:id] = MiniActiveRecord::Model.last_insert_row_id
      results
    end

    def update!
      self[:updated_at] = DateTime.now

      fields = self.attributes.keys
      values = self.attributes.values

      update_clause = fields.map { |field| "#{field} = ?" }.join(',')
      update_sql = "UPDATE #{self.class}s SET #{update_clause} WHERE id = ?"

      # We have to use the (potentially) old ID attribute in case the user has re-set it.
      MiniActiveRecord::Model.execute(update_sql, *values, self.old_attributes[:id])
    end


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
