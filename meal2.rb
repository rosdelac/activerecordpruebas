class Meal < MiniActiveRecord::Model
  def self.all
    MiniActiveRecord::Model.execute("SELECT * FROM meals").map do |row|
      Meal.new(row)
    end
  end
  #probado
  def self.create(attributes)
    record = self.new(attributes)
    record.save

    record
  end
  #probado
  def self.where(query, *args)
    MiniActiveRecord::Model.execute("SELECT * FROM meals WHERE #{query}", *args).map do |row|
      Meal.new(row)
    end
  end
  #probado
  def self.find(pk)
    self.where('id = ?', pk).first
  end

  self.attribute_names = [:id, :name, :chef_id, :created_at, :updated_at]

  attr_reader :attributes, :old_attributes

  # e.g., Meal.new(id: 1, name: 'Chicken', created_at: '2012-12-01 05:54:30')
  def initialize(attributes = {})
    super
  end
  #probado
  def [](attribute)
    super
  end
  #probado
  def []=(attribute, value)
    super
  end

  def chef
    Chef.where('id = ?', self[:chef_id])
  end

  def chef=(chef)
    self[:chef_id] = chef[:id]
    self.save

    chef
  end
  #probado
  def new_record?
    self[:id].nil?
  end
  #probado
  def save
    super
  end


  private
  #probado
  def insert!
    self[:created_at] = DateTime.now
    self[:updated_at] = DateTime.now

    fields = self.attributes.keys
    values = self.attributes.values
    marks  = Array.new(fields.length) { '?' }.join(',')

    insert_sql = "INSERT INTO meals (#{fields.join(',')}) VALUES (#{marks})"

    results = MiniActiveRecord::Model.execute(insert_sql, *values)

    # This fetches the new primary key and updates this instance
    self[:id] = MiniActiveRecord::Model.last_insert_row_id
    results
  end
  #probado
  def update!
    self[:updated_at] = DateTime.now

    fields = self.attributes.keys
    values = self.attributes.values

    update_clause = fields.map { |field| "#{field} = ?" }.join(',')
    update_sql = "UPDATE meals SET #{update_clause} WHERE id = ?"

    # We have to use the (potentially) old ID attribute in case the user has re-set it.
    MiniActiveRecord::Model.execute(update_sql, *values, self.old_attributes[:id])
  end
end
