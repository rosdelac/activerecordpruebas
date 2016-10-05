class Meal < MiniActiveRecord::Model
  def self.all
    super
  end
  #probado
  def self.create(attributes)
    super
  end
  #probado
  def self.where(query, *args)
    super
  end
  #probado
  def self.find(pk)
    super
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
    super
  end
  #probado
  def save
    super
  end


  private
  #probado
  def insert!
    super
  end
  #probado
  def update!
    super
  end
end
