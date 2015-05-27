class QueryColumn

  attr_accessor :name, :caption, :association_name, :field_id, :organization_id

  def initialize(name, options={})
    self.name = name
    #self.association_name = association_name
    self.caption = options[:caption]
    self.field_id = options[:field_id]
    self.organization_id = options[:organization_id]
  end

  def value(object)
    object.send name
  end

  def value_object(object)
    object.send name
  end

  def project_field_value(object)
    field = Field.find(self.field_id)
    value = '-'
    unless field.coefficient.nil?
      project_field = ProjectField.where(field_id: self.field_id, project_id: object.id).last
      #value = project_field.nil? ? '-' : convert_with_precision(project_field.value.to_f / field.coefficient.to_f, user_number_precision)
      value = project_field.nil? ? '-' : convert_with_precision(project_field.value.to_f / field.coefficient.to_f, 2)
    end
    value
  end

  def css_classes
    name
  end

  def convert_with_precision(value, precision)
    "%.#{precision}f" % value
  end

end