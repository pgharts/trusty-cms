class Status
  attr_accessor :id, :name

  def initialize(options = {})
    options = options.symbolize_keys
    @id = options[:id]
    @name = options[:name]
  end

  def symbol
    @name.to_s.downcase.intern
  end

  def self.[](value)
    @@statuses.find { |status| status.symbol == value.to_s.downcase.intern }
  end

  def self.find(id)
    @@statuses.find { |status| status.id.to_s == id.to_s }
  end

  def self.selectable
    @@statuses
  end

  def self.selectable_values
    selectable.map(&:name)
  end

  @@statuses = [
    Status.new(id: 1,   name: 'Draft'),
    Status.new(id: 50,  name: 'Reviewed'),
    Status.new(id: 90,  name: 'Scheduled'),
    Status.new(id: 100, name: 'Published'),
    Status.new(id: 101, name: 'Hidden'),
  ]
end
