class AddIsImageOrganizationToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_image_organization, :boolean
  end
end
