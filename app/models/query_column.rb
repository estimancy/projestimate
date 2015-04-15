class QueryColumn
  attr_accessor :name, :caption, :association_name

  def initialize(name, options={})
    self.name = name
    #self.association_name = association_name
    self.caption = options[:caption]
  end

  def value(object)
    object.send name
  end

  def value_object(object)
    object.send name
  end

  def css_classes
    name
  end
end