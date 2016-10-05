class Chef < MiniActiveRecord::Model
  def self.all
    super
  end

  def self.create(attributes)
    super
  end

  def self.where(query, *args)
    super
  end

  def self.find(pk)
    super
  end

  self.attribute_names = [:id, :first_name, :last_name, :email, :phone,
                          :birthday, :created_at, :updated_at]

  attr_reader :attributes, :old_attributes

  # e.g., Chef.new(id: 1, first_name: 'Steve', last_name: 'Rogers', ...)
  def initialize(attributes = {})
    super
  end

  def save
    super
  end

  # We say a record is "new" if it doesn't have a defined primary key in its
  # attributes
  def new_record?
    super
  end

  # e.g., chef[:first_name] #=> 'Steve'
  def [](attribute)
    super
  end

  # e.g., chef[:first_name] = 'Steve'
  def []=(attribute, value)
    super
  end

  def meals
    Meal.where('chef_id = ?', self[:id])
  end

  def add_meals(meals)
    meals.each do |meal|
      meal.chef = self
    end

    meals
  end


  private

  def insert!
    super
  end

  def update!
    super
  end
end
